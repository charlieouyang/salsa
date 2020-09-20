import factory

from salsa import models

from .base import ModelFactory
from .product import ProductFactory
from .category import CategoryFactory


class ProductCategoryFactory(ModelFactory):
    product = factory.SubFactory(ProductFactory)
    category = factory.SubFactory(CategoryFactory)

    class Meta:
        model = models.ProductCategory
