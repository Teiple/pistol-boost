#import "@preview/polylux:0.4.0": *
#import "@preview/jotter-polylux:0.1.0": framed-block, post-it, setup, title-slide

#set text(
  size: 18pt,
  font: "Comic Neue",
  fill: blue.darken(50%),
)

#show link: underline

#show image: set image(scaling: "smooth")

#show: setup.with(
  header: [Teiple],
  highlight-color: green.transparentize(30%),
  binding: true,
  dots: true,
)

#title-slide[Pistol Boost][
  Game Design Document \
  by _Teiple_

  #place(
    horizon + right,
    post-it[
      #set align(horizon + left)
      #set text(size: .6em)
      First time doing a GDD ever!
    ],
  )
]

#slide(outline())

#slide[
  = Overview <overview>
  #toolbox.register-section("Overview")
  Main ideas for *Pistol Boost* (PB):
  #toolbox.side-by-side[
    #framed-block[Control a pistol that can only move by _firing_.]

    #framed-block[Fighting in an arena of a variety of enemy bots.]

    #framed-block[Gaining various power-ups with special attacks.]

  ][
    #image(
      "pistol_boost_legacy.png",
      height: 60%,
      fit: "cover",
      scaling: "smooth",
    )
  ]

]

#slide[
  #toolbox.side-by-side[
    #image(
      "pistol_boost_thumbnail.png",
      height: 70%,
      fit: "cover",
    )
  ][
    Idea was from my prev game, also called *Pistol Boost* (#link("https://teiple.itch.io/pistol-boost")[Itch.io]). From it'd referred as *Pistol Boost Legacy* (PBL).

    Some characteristic of PBL:
    #framed-block[Focus on high-score and wave progression]

    #framed-block[Enemy variants are gradually introduced]

    #framed-block[A handful of power-ups that enables interesting attacks]
  ]
]

#slide[
  = Gameplay
  == Goals
  The game focuses strongly on physics-based movement, intense bullet hells, quick reflexes, simple controls, readable enemy archetypes, arcade loop and fun.

  On development side, this should be the first time I actively working on a production-like game, where I can actively manage documents, data, workflows and implementation of things.
]

#slide[
  == Core
  Player have two firing modes. On default, both have _infinite_ ammo:
  #toolbox.side-by-side[
    1. Primary:
      - Shoot one projectile
      - High accuracy
      - Change shoot behavior when applied _power-ups_
      - Minimal pushback
      - High damage
    -> Combat centric
  ][
    2. Secondary:
      - Shotgun-like shoot behavior
      - Poor accuracy
      - Huge pushback
      - Never change behavior
      - Low damage
    -> Movement centric
  ][
    #box(post-it[
      Primary

      - Single shot
      - Use for power-ups
    ])
    #box(post-it[
      Secondary

      - Blast shot
      - Mean of movement
    ])
  ]


  #toolbox.side-by-side[
    === Moving
    The player moves by shooting either their primary or secondary and uses the recoil to push them in the opposite direction:
    #image(
      "pistol_move.png",
      height: 50%,
      width: 100%,
      fit: "contain",
    )
  ][
    === Aiming
    The player always tries to aim at the cursor position, and the gun will always tries to stay up right:

    #image("pistol_aim.png", height: 50%, width: 100%, fit: "contain")
  ]

]

