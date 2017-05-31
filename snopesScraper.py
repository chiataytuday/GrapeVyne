import bs4, json, requests

lastPageSoup = bs4.BeautifulSoup(requests.get("http://www.snopes.com/category/facts").text, "html.parser")
lastPage = int(lastPageSoup.find("span", {"class":"page-count"}).text.split()[-1].encode('ascii', 'ignore'))

jsonDict = {"articles":[]}

for i in range(1, lastPage + 1):
	pageSoup = bs4.BeautifulSoup(requests.get("http://www.snopes.com/category/facts/page/%s/" %i).text, 'html.parser')
	headlines = pageSoup.findAll("h2", {"class":"article-link-title"})

	for headline in headlines:
		if headline.text and headline.text[-1] == "?":
			headlineUrl = headline.parent.get('href')
			headlineSoup = bs4.BeautifulSoup(requests.get(headlineUrl).text, 'html.parser')
			headlineDivs = headlineSoup.find("div", {"class":"entry-content article-text legacy"}).findAll("div")

			for headlineDiv in headlineDivs:
				if headlineDiv.get('class') and headlineDiv.get('class')[0] == 'claim':
					jsonDict["articles"].append({"url":headlineUrl, "title":headline.text.encode('ascii', 'ignore'), "fact":headlineDiv.get('class')[1].encode('ascii', 'ignore')})
					jsonObj = json.dumps(jsonDict, indent = 4)

        print("Round %s finished" %i)

with open("articles.json", "w") as f:
	f.write(jsonObj)
