pull:
	git pull origin master gh-pages --tags

push:
	git push origin master gh-pages --tags

reset-website:
	@git branch -D gh-pages
	@git branch --track gh-pages origin/gh-pages
