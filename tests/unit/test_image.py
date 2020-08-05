import uuid
from unittest import mock
from parameterized import parameterized
from werkzeug.exceptions import Forbidden

from tests import SalsaTestCase
from tests import basic_user

from salsa.image import upload


class TestImage(SalsaTestCase):
    def test_upload(self):
        mock_get_user = mock.patch(
            'salsa.image.get_user').start()
        user_id = str(uuid.uuid4())
        mock_get_user.return_value = basic_user(user_id=user_id)

        mock_request = mock.patch(
            'salsa.image.request').start()
        files = [mock.MagicMock(), mock.MagicMock()]
        mock_request.files.getlist.return_value = files

        mock_google = mock.patch(
            'salsa.image.storage').start()

        mock_stat = mock.MagicMock()
        mock_stat.st_size = 10000
        mock_os = mock.patch(
            'salsa.image.os').start()
        mock_os.stat.return_value = mock_stat

        mock_timestamp = mock.patch(
            'salsa.image._current_timestamp').start()
        mock_timestamp.return_value = 123456789

        upload(sample={})

        os_stat_calls = []
        google_init_file_calls = []
        remove_calls = []
        for idx, file in enumerate(files):
            file_path = f'{user_id}_123456789_{idx}.png'

            # Save file to disk
            file.save.assert_called_with(f'salsa/image_store/{file_path}',
                                         buffer_size=65536)

            # Check the size of the files
            os_stat_calls.append(mock.call(f'salsa/image_store/{file_path}'))
            file.close.assert_called()

            # Upload the file to bucket and get URL
            # NO TESTING FOR BUCKET UPLOAD CODE..

            # Remove file from disk
            remove_calls.append(mock.call(f'salsa/image_store/{file_path}'))

        mock_os.stat.assert_has_calls(os_stat_calls)
        mock_os.remove.assert_has_calls(remove_calls)
