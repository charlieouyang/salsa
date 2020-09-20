import unittest
import uuid

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import Category
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests.factories import CategoryFactory


class CategoryTest(SalsaTestCase):
    def test_valid_category(self):
        category = CategoryFactory(name='category_name')

        self.assertEqual([category], db.session.query(Category).all())
        self.assertEqual(category.name, 'category_name')

    def test_category_duplicate_invalid(self):
        category = CategoryFactory(name='category_name')

        with self.assertRaises(IntegrityError):
            CategoryFactory(name='category_name')

    def test_find_by_id_success(self):
        category = CategoryFactory(name='category_name')
        es = Category.find_by_id(category.id)
        self.assertEqual(category, es)

    def test_find_by_ids_success(self):
        categories = [CategoryFactory(), CategoryFactory()]
        es = Category.find_by_ids([categories[0].id, categories[1].id])
        self.assertEqual(categories, es)

    def test_find_by_ids_fail(self):
        with self.assertRaises(ResourceNotFoundError):
            Category.find_by_ids([uuid.uuid4()])


if __name__ == '__main__':
    unittest.main()
