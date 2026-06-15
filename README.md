# NYC Lunch Carousel

A spinning 3D carousel that picks a lunch spot for the NYC office. Started life as
an iOS app for our wall-mounted iPad mini; there's now also a lightweight web app.

## Web app (current)

A lightweight **Vite + TypeScript** port that recreates the 3D wheel with plain CSS
3D transforms — no framework, no canvas/WebGL. Lives in [`web/`](web/).

**Live:** https://lauriboren.github.io/lunch-carousel/

```bash
cd web
npm install
npm run dev      # http://localhost:5173
npm run build    # static build into web/dist
```

Each card shows the restaurant name with its address and walking time. See
[web/README.md](web/README.md) for the full details and the iOS→web mapping. The
site deploys automatically to GitHub Pages on every push to `main` that touches
`web/`.

## iOS app (original)

The original **Swift / UIKit** implementation, written by
[Timo](https://github.com/timojaask). Lives in [`carousel-3d/`](carousel-3d/).

Hacked together in a hurry -- don't judge!

Intended for our wall-mounted iPad mini, but works on iPhone as well. The supported
version is set to 12 because that's what our iPad is running -- it's been
discontinued, and that's the latest iOS version it'll ever get.

Figma: https://www.figma.com/file/6xXFuF5DDyc7xlsfsf3aWD/Lunch-bingo?type=design&node-id=0-1&mode=design&t=QE81FXgZ7i3BXJyy-0

### Screenshots
<img src="https://github.com/reaktor/nyc-launch-carousel-ios/assets/3090208/c55aaf05-38a5-4235-9dfa-ae0bef3bb8f5" width="200" />
<img src="https://github.com/reaktor/nyc-launch-carousel-ios/assets/3090208/79cf8c80-f88e-45d9-acff-5ae6f55e1e3a" width="200" />
<img src="https://github.com/reaktor/nyc-launch-carousel-ios/assets/3090208/b4115553-11d5-4469-8b77-63527621b8c3" width="200" />
<img src="https://github.com/reaktor/nyc-launch-carousel-ios/assets/3090208/e73eb306-907c-4a3f-84dc-a1a2734c5e68" width="200" />
