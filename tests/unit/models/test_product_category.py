import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import Product, Category, ProductCategory
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests.factories import (CategoryFactory,
                             ProductFactory,
                             ProductCategoryFactory)


class ProductCategoryTest(SalsaTestCase):
    def test_valid_product_category(self):
        product_category = ProductCategoryFactory()

        self.assertEqual([product_category],
                         db.session.query(ProductCategory).all())

    def test_find_by_id_success(self):
        product_category = ProductCategoryFactory()
        es = ProductCategory.find_by_id(product_category.id)
        self.assertEqual(product_category, es)

    def test_one_product_multiple_categories(self):
        product = ProductFactory()
        categories = [CategoryFactory() for _ in range(3)]

        product_categories = [ProductCategoryFactory(product=product,
                                                     category=categories[0]),
                              ProductCategoryFactory(product=product,
                                                     category=categories[1]),
                              ProductCategoryFactory(product=product,
                                                     category=categories[2]),]

        instances = db.session.query(ProductCategory).all()
        self.assertEqual(product_categories, instances)

    def test_multiple_products_one_category(self):
        category = CategoryFactory()
        products = [ProductFactory() for _ in range(3)]

        product_categories = [ProductCategoryFactory(product=products[0],
                                                     category=category),
                              ProductCategoryFactory(product=products[1],
                                                     category=category),
                              ProductCategoryFactory(product=products[2],
                                                     category=category),]

        instances = db.session.query(ProductCategory).all()
        self.assertEqual(product_categories, instances)

    def test_multiple_product_multiple_categories(self):
        categories = [CategoryFactory() for _ in range(3)]
        products = [ProductFactory() for _ in range(3)]

        product_categories = [ProductCategoryFactory(product=products[0],
                                                     category=categories[0]),
                              ProductCategoryFactory(product=products[1],
                                                     category=categories[0]),
                              ProductCategoryFactory(product=products[2],
                                                     category=categories[0]),
                              ProductCategoryFactory(product=products[0],
                                                     category=categories[1]),
                              ProductCategoryFactory(product=products[1],
                                                     category=categories[1]),
                              ProductCategoryFactory(product=products[2],
                                                     category=categories[1]),
                              ProductCategoryFactory(product=products[0],
                                                     category=categories[2]),
                              ProductCategoryFactory(product=products[1],
                                                     category=categories[2]),
                              ProductCategoryFactory(product=products[2],
                                                     category=categories[2]),]

        instances = db.session.query(ProductCategory).all()
        self.assertEqual(product_categories, instances)

    def test_invalid_product_category(self):
        product = ProductFactory()
        category = CategoryFactory()

        valid_product_categories = ProductCategoryFactory(
            product=product, category=category)

        with self.assertRaises(IntegrityError):
            ProductCategoryFactory(
                product=product, category=category)

if __name__ == '__main__':
    unittest.main()
