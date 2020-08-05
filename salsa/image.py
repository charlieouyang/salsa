# Authentication
import time
import os
import random

import connexion
import six
import toolz as T
from werkzeug.exceptions import (BadRequest,
                                 InternalServerError)

from google.cloud import storage

from flask import request

from salsa.db import db
from salsa.permission import get_user, get_user_id_from_user

NUM_FILES_ERROR_MSG = 'Upload up to 5 images in a request'
BUCKET_CONNECTION_ERROR_MSG = 'Error in connecting to bucket'
BUCKET_UPLOAD_ERROR_MSG = 'Error in uploading image to bucket'
IMAGE_TOO_LARGE_ERROR_MSG = 'Images can have a maximum size of 5 MB'
FILE_SAVE_ERROR_MSG = 'Error in saving the file'
FILE_SIZE_CHECK_ERROR_MSG = 'Error in checking size of the file'
FILE_REMOVAL_ERROR_MSG = 'Error in removing file from temp location'

LOCAL_IMAGE_STORE_PATH = 'salsa/image_store/'
BUCKET_URL_PREFIX = 'https://storage.googleapis.com/chinese_goods/image_store'
#5MB
MAX_FILE_SIZE = 5000000


def _current_timestamp() -> int:
    return int(time.time())

def upload(**kwargs):
    """
    Upload images to google bucket, and return the urls

    file_name = user_name + timestamp + file_index
    """
    user_id = get_user_id_from_user(get_user(kwargs))

    # Validate number of files in the request
    uploaded_files = request.files.getlist("file")

    if len(uploaded_files) == 0 or len(uploaded_files) > 5:
        raise BadRequest(description=NUM_FILES_ERROR_MSG)

    # Try to connect to the bucket
    try:
        storage_client = storage.Client.from_service_account_json(
            os.environ.get('STORAGE_BUCKET_CREDENTIAL_PATH'))

        bucket = storage_client.get_bucket('chinese_goods')
    except Exception as error:
        raise InternalServerError(
            description=f'{BUCKET_CONNECTION_ERROR_MSG}: {error}')

    # Try to upload the images to the bucket
    file_urls = []
    for idx, file in enumerate(uploaded_files):
        # Save file to disk
        try:
            file_path = f'{user_id}_{_current_timestamp()}_{idx}.png'
            local_file_path = LOCAL_IMAGE_STORE_PATH + file_path
            file.save(local_file_path, buffer_size=65536)

            raise ValueError()
        except Exception as error:
            raise InternalServerError(
                description=f'{FILE_SAVE_ERROR_MSG}: {error}')

        # Check the size of the files
        try:
            file_length = os.stat(local_file_path).st_size
            if file_length > MAX_FILE_SIZE:
                raise BadRequest(description=IMAGE_TOO_LARGE_ERROR_MSG)
            file.close()
        except BadRequest as error:
            raise error
        except Exception as error:
            raise InternalServerError(
                description=f'{FILE_SIZE_CHECK_ERROR_MSG}: {error}')

        # Upload the file to bucket and get URL
        try:
            image_loc = bucket.blob(f'image_store/{file_path}')
            image_loc.upload_from_filename(filename=local_file_path)
            file_urls.append(f'{BUCKET_URL_PREFIX}/{file_path}')
        except Exception as error:
            raise InternalServerError(
                description=f'{BUCKET_UPLOAD_ERROR_MSG}: {error}')

        # Remove file from disk
        try:
            os.remove(local_file_path)
        except Exception as error:
            raise InternalServerError(
                description=f'{FILE_REMOVAL_ERROR_MSG}: {error}')

    return {'status_code': 201,
            'message': 'Image upload success!',
            'file_urls': file_urls}

