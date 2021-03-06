"""
    Test server disponibility
"""
import pytest
import requests
import lxml.etree as etree

from urllib.parse import urlparse

ns = { "wms": "http://www.opengis.net/wms" }

xlink = "{http://www.w3.org/1999/xlink}"
 
@pytest.mark.skip(reason="This test randomly fail, need to investigate")
def test_wfs_segfault( host ):
    """ Test that wfs request return a result
        see https://projects.3liz.org/infra-v3/py-qgis-server/issues/3
    """
    urlref = ("http://{}/ows/?map=no_wfs.qgs&request=GetFeature&service=WFS"
              "&typename=Near_real_time_deforestation&version=1.0.0").format( host )
    rv = requests.get( urlref )
    assert rv.status_code < 500

