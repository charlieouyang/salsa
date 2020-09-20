import json
import os


def load_json_fixture(file_name, directory=None):
    basedir = os.path.abspath(os.path.dirname(__file__))
    if directory:
        basedir = os.path.join(basedir, directory)
    fixture_path = os.path.join(basedir, file_name)

    with open(fixture_path, 'r', encoding='utf-8') as f:
        return json.load(f)
