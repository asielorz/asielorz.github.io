## Building the page

We use `elm-pages dev` to run a server on localhost that serves the page and updates content live as it changes. You can run it like this:

```sh
npx elm-pages@3.0 dev
```

To build the release version of the page, to be uploaded to GitHub pages, run this command:

```sh
npx elm-pages@3.0 build
```

## Update RSS

Currently, the RSS feed needs to be updated manually every time a new post is added. To do so, run this command:

```sh
npx elm-pages@3.0 run script/src/Rss.elm
```
