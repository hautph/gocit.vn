import requests
from bs4 import BeautifulSoup
import os
import unidecode
 
def download(item, folder):
    url = "http:{}".format(item["source"]["128"])
    r = requests.get(url, stream=True)
    filename = "{}.mp3".format(unidecode.unidecode(item["name"]))
    with open(os.path.join(folder, filename), 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)
    print "Done {}".format(filename)
    return filename
 
#album_url = "https://mp3.zing.vn/album/Nhung-Bai-Hat-Hay-Nhat-Cua-Vu-Vu/ZOAFW0WC.html"
album_url = raw_input("ZingMP3 album URL: ")
soup = BeautifulSoup(requests.get(album_url).text, "lxml")
data_xml = soup.find("div", attrs={"id": "zplayerjs-wrapper"})["data-xml"]
album_url_api = "https://mp3.zing.vn/xhr{}".format(data_xml)
album_response = requests.get(album_url_api)
data = album_response.json()["data"]
folder = unidecode.unidecode(data["info"]["name"])
print folder
items = data["items"]
 
if not os.path.exists(folder):
    os.makedirs(folder)
 
for item in items:
    download(item, folder)
