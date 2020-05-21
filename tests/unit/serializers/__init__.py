import datetime
import uuid


class SerializerTestCase:
    def _compare_attrs(self, attrs, dct, instance, skip=None):
        for f in attrs:
            if skip and f in skip:
                continue
            self.assertTrue(f in dct, 'Serialized {} has key {}'.format(
                instance.__class__.__name__, f))
            val = getattr(instance, f, None)
            if val is not None:
                f_cls = val.__class__
                if f_cls == datetime.datetime:
                    val = val.isoformat() + '+00:00'
                elif f_cls == uuid.UUID:
                    val = str(val)
            self.assertEqual(dct[f], val)

    def test_simple(self):
        instance = self.factory()
        serializer = self.serializer(exclude=self.RELATIONS)

        result = serializer.dump(instance).data

        self._compare_attrs(self.PLAIN_ATTRS, result, instance)
        # no unexpected keys
        self.assertFalse(set(result.keys()) - self.ALL_ATTRS)
        # relations properly excluded
        self.assertFalse(set(result.keys()) & self.RELATIONS)
