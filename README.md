# styled_video_player

Styled_video_player package is based on video_player package
Make sure the use last flutter version.

![example](https://i.imgur.com/5BxFE6g.gif)

# optional about window

![about](https://i.imgur.com/9sej3mw.gif)

# language customization

![language](https://i.imgur.com/GLA7qx3.gif)
![language2](https://i.imgur.com/qnUhE1w.gif)

## Usage

- videoUrl and videoName params are required
- about parameter is optional

```
Player(
              videoUrl:
                  'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
              videoName: 'My Video',
              about: "This about window is optional",
    ),
```

## With Custom Language

```
Player(
              videoUrl:
                  'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
              videoName: 'Mon Vidéo',
              about: "Cette fenêtre à propos est facultative",
              aboutText: "A propos de",
              opacityText: "L'opacité",
              speedText: "La vitesse",
              volumeText: "Le volume"),
```
