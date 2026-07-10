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
    ==== Takes and lessons learned

    Need to create power-ups that are:

    #box(post-it[
      Mechanically fun

      Visually interesting
    ])
    #box(post-it[
      Work in various cases

      Easy to control
    ])
    #box(post-it[
      Different from other power-ups
    ])
  ][
    ==== What will be there for PB
    PB aims to:new
    - #framed-block([
        Remove niche, similar power-ups
      ])

    - #framed-block([
        Add more power-ups variety
      ])

    - #framed-block([
        Keeping replacement model from PBL
      ])
  ]

  #pagebreak()

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

  #pagebreak()

  == Enemy Archetypes
  === Overview
  #toolbox.side-by-side[
    #toolbox.side-by-side[
      #image("pbl_turret.png", height: 25%, fit: "contain")
      Turret
    ][
      #image("pbl_robot.png", height: 25%, fit: "contain")
      Robot
    ]
    #toolbox.side-by-side[
      #image("pbl_crawler.png", height: 25%, fit: "contain")
      Crawler
    ][
      #image("pbl_drone.png", height: 25%, fit: "contain")
      Drone
    ]
  ][
    Enemies poses a vital role in the game.

    The enemies, along with their projectiles and their shooting behavior force the player to:

    - Contanstly move around

    - Have a strategy of deal with them through precise physical movement and suitable choices of power-ups

    Throughout the wave progression, multiple enemy archetypes will be introduce gradually, pairing up with the last ones to create a smooth and fair transition
  ]

  #pagebreak()

  === Turret
  Turret is the most basic enemy type in the game which stationary position and predictable shooting behavior.

  #toolbox.side-by-side[
    #image("pbl_turret.png", fit: "contain", width: 100%)
  ][
    Turrets spawn at specified points on the map and never move.

    A turret has basically two states:

    - Idle: the turret's cannon rotates to neutral position

    - Combat: actively aiming its cannon and shooting
  ][
    They switch to combat state and open fire in the player's direction _upon having visual contact_

    Shooting behavior:

    - *Burst*: 2 continuous shots at a time

    - *Predictive*: shooting ahead of the player based on player's velocity
  ]


]
