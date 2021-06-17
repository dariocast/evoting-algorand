import sys
from flask_mongoengine import MongoEngine
from mongoengine import connect

db: MongoEngine = MongoEngine()


def __load_obj(import_name):
    try:
        __import__(import_name)
    except ImportError:
        if "." not in import_name:
            raise
    else:
        return sys.modules[import_name]

    module_name, obj_name = import_name.rsplit(".", 1)
    module = __import__(module_name, globals(), locals(), [obj_name])
    try:
        return getattr(module, obj_name)

    except AttributeError as e:
        raise ImportError(e)


def config_from_object(import_name):
    obj = __load_obj(import_name)
    data = {}
    for key in dir(obj):
        if key.isupper():
            data[key] = getattr(obj, key)
    connect(
        data['MONGODB_DB'],
        host=data.get('DATABASE_HOST'),
        port=data.get('DATABASE_PORT'),
        username=data.get('DATABASE_USER'),
        password=data.get('DATABASE_PASSWORD')
    )
