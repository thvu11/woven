# pronton woven coding challenge

## Installation and running test/program

The code is developed under docker and docker compose 

```
Docker version 29.9.2, build a82e528
Docker Compose version v5.6.1
```

To run the program. Modify `app.command` in the `compose.yaml` file to change your flags

```
# ROLL=1 => run rolls_1.json, ROLL=2 => run rolls_2.json, etc
ROLL=<integer> docker compose run --rm app
```

To run the test

```
docker compose run --rm test
```

## Assumptions

- the game can have multiple winners (ie. two or more players tie at the top)
- players have to go pass GO again to receive bonus (re-landing on GO counts too)
- bankruptcy means money goes negative


## Sample output

`rolls_1.json`

```json
{
  "winner": "Peter",
  "players": [
    {
      "name": "Peter",
      "money": 40,
      "space": "Massizim"
    },
    {
      "name": "Billy",
      "money": 14,
      "space": "GO"
    },
    {
      "name": "Sweedal",
      "money": 1,
      "space": "Gami Chicken"
    },
    {
      "name": "Charlotte",
      "money": -1,
      "space": "Gami Chicken"
    }
  ]
}
```

`rolls_2.json`

```json
{
  "winner": "Charlotte",
  "players": [
    {
      "name": "Charlotte",
      "money": 31,
      "space": "GO"
    },
    {
      "name": "Billy",
      "money": 20,
      "space": "Fast Kebabs"
    },
    {
      "name": "Peter",
      "money": 5,
      "space": "Lanzhou Beef Noodle"
    },
    {
      "name": "Sweedal",
      "money": -2,
      "space": "Massizim"
    }
  ]
}
```

A `rolls_3.json` is added to demonstrate the program can have multiple winners at the end

## Design

```ruby
require_relative "monopoly/property"
require_relative "monopoly/space"
require_relative "monopoly/player"
require_relative "monopoly/board"
require_relative "monopoly/game"
require_relative "monopoly/report"
```

`board` loads cells, looks up a cell by index/color, keep track of color group ownership

Two separate types of cell:
- `property`: contains details of the property and its ownership
- `space`: special case for GO cell

`player` keeps track of money, name, position on the board and pay/receive money action

`game` takes a board, players, rolls to initiate the game loop and implement all game logic
