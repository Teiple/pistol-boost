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
    #image(
      "pbl_primary_fire.png",
      height: 35%,
      width: 100%,
      fit: "contain",
    )
    #image(
      "pbl_secondary_fire.png",
      height: 35%,
      width: 100%,
      fit: "contain",
    )
  ][
    #box(post-it[
      Primary

      - Single shot
      - Use for power-ups
    ])
    #box(post-it[
      Secondary

      - Blast shot
      - Means of movement
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

    #image("pistol_aim.png", width: 100%, height: 50%, fit: "contain")
  ]
  \
  #toolbox.side-by-side[
    === Power-ups
    *Power-ups* are small modification on the player's primary fire. They can be _dropped by enemies upon destroyed_.
    #toolbox.side-by-side[
      #image("power_up_1.png", width: 100%, height: 25%, fit: "contain")
    ][
      #image("power_up_2.png", width: 100%, height: 25%, fit: "contain")
    ][
      #image("power_up_3.png", width: 100%, height: 25%, fit: "contain")
    ]
    Power-ups change the player's _primary fire_.
    Power-up mod always have _limited ammo_

    Like PBL, picking up a new power-up _replaces_ the current one.
  ][
    An example of PBL's powerups:
    #image("pbl_ricochet.png", height: 60%, width: 100%, fit: "contain")
    *Ricochet* (prev called *Wallet Bouncing*):
    - Bullet to bounce from wall at max twice
    - Auto-correct direction on bounce to hit nearby enemies
  ]

  #toolbox.side-by-side[
    ==== What worked for PBL
    1. *Full-Auto*: Continous firing when primary key is held down:     High fire-rate. Low Damage Per Shot. Very High ammo. Accumulative recoil
    -> Can be used for quick gun-down or traversal
    2. *Wall Pierce*: Bullets pass through walls and the entire map: Very High Damage. Very Low Ammo.
    -> Fun but a bit too overpowered
    3. *Ricochet*: Bullets bounce twice and auto-correct trajectory toward nearby enemies
    -> Visually interesting, encourages creative shot based on map structure
  ][
    ==== What didn't work for PBL
    1. *Enemy Piercing*
    Bullets pierce multiple enemies.

    -> Rarely useful because enemy formations seldom lined up due to map and spawn pattern design.

    2. *Multi-Shot*
    Fires multiple bullets in the same direction.

    -> The total damage is just a bit higher standard shot. Only widen the shooting area abit. Not interesing enough.
  ]

  #toolbox.side-by-side[
    ==== Takes and lessons leanred

    Need to create power-ups that are:
    #framed-block([
      - Mechanically fun
      - Visually interesting
      - Distinct on its own
      - Work in various cases
      - Easy to control
    ])

    ==== What will be there for PB
    PB aims to:
    #framed-block([
      - Remove niche, similar power-ups/

      - Add more power-ups variety

      - Keeping replacement model from PBL
    ])
  ][
    ==== A note of PBL's power-up replacement model
    PBL's replacement model was simple: one active power-up, and picking up a new one replaces the current one.

    Compared to stacking and managing multiple power-ups, this keeps controls minimal and avoids extra UI or cycling buttons.

    It also creates quick decisions:
    #framed-block([
      - Take the new power-up and adapt

      - Avoid it if the current one fits better

      - Risk losing a strong power-up in a tense moment
    ])
  ]

  #toolbox.side-by-side[
    ==== New power-up ideas
    PB should bring back the strongest PBL ideas and add more experimental primary-fire mods:

    #toolbox.side-by-side[
      - *Dash*: Quick burst movement that damage enemies at close distance

      - *Homing Missiles*: Projectiles seek enemies

      - *Shield*: Not actually a firing mode; shields player from damage for a period of time
    ][
      - *Laser Beam*: Continuous high-damage attack

      - *EMP Gun*: Disable enemies in an area briefly
    ]
  ]
]
