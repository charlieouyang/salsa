import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import UserAccount, Product
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests import admin_user, basic_user
from tests.factories import UserAccountFactory, ProductFactory, ReviewFactory


class ProductTest(SalsaTestCase):
    def test_valid_product(self):
        product = ProductFactory(name='product_name')

        self.assertEqual([product], db.session.query(Product).all())
        self.assertEqual(product.name, 'product_name')
        self.assertEqual(product.avg_numstars, -1)

    def test_valid_product_avg_numstars(self):
        product = ProductFactory(name='product_name')
        ReviewFactory(product=product, numstars=1)
        ReviewFactory(product=product, numstars=2)
        ReviewFactory(product=product, numstars=3)

        self.assertEqual(product.name, 'product_name')
        self.assertEqual(product.avg_numstars, 2)

    def test_find_by_id_success(self):
        product = ProductFactory(name='product_name')
        es = Product.find_by_id(product.id)
        self.assertEqual(product, es)

    @parameterized.expand([
        (admin_user(), True),
        (admin_user(), False),
        (basic_user(), True),
    ])
    def test_can_update_by_ids_for_user_success(self, user, use_same_user):
        if use_same_user:
            product = ProductFactory()
            user['usr']['id'] = str(product.user_id)
        else:
            product = ProductFactory()

        res = Product.can_update_ids_by_user([product.id], user)
        self.assertEqual([product], res)

    def test_can_update_by_ids_for_user_failure(self):
        product = ProductFactory()

        user = basic_user()
        another_account = UserAccountFactory()
        user['usr']['id'] = str(another_account.id)

        with self.assertRaises(ResourceNotFoundError):
            Product.can_update_ids_by_user([product.id], user)


if __name__ == '__main__':
    unittest.main()
