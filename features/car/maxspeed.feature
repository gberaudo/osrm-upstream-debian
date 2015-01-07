@routing @maxspeed @car
Feature: Car - Max speed restrictions
OSRM will use 4/5 of the projected free-flow speed.

    Background: Use specific speeds
        Given the profile "car"
        Given a grid size of 1000 meters

    Scenario: Car - Respect maxspeeds when lower that way type speed
        Given the node map
            | a | b | c | d | e | f | g |

        And the ways
            | nodes | highway | maxspeed    |
            | ab    | trunk   |             |
            | bc    | trunk   | 60          |
            | cd    | trunk   | FR:urban    |
            | de    | trunk   | CH:rural    |
            | ef    | trunk   | CH:trunk    |
            | fg    | trunk   | CH:motorway |

        When I route I should get
            | from | to | route | speed         |
            | a    | b  | ab    |  78 km/h      |
            | b    | c  | bc    |  59 km/h +- 1 |
            | c    | d  | cd    |  50 km/h      |
            | d    | e  | de    |  75 km/h      |
            | e    | f  | ef    |  90 km/h      |
            | f    | g  | fg    | 105 km/h      |

    Scenario: Car - Do not ignore maxspeed when higher than way speed
        Given the node map
            | a | b | c | d |

        And the ways
            | nodes | highway       | maxspeed |
            | ab    | residential   |          |
            | bc    | residential   | 90       |
            | cd    | living_street | FR:urban |

        When I route I should get
            | from | to | route | speed        |
            | a    | b  | ab    | 31 km/h      |
            | b    | c  | bc    | 83 km/h +- 1 |
            | c    | d  | cd    | 50 km/h      |

    Scenario: Car - Forward/backward maxspeed
        Given a grid size of 100 meters

        Then routability should be
            | highway | maxspeed | maxspeed:forward | maxspeed:backward | forw    | backw   |
            | primary |          |                  |                   | 65 km/h | 65 km/h |
            | primary | 60       |                  |                   | 60 km/h | 60 km/h |
            | primary |          | 60               |                   | 60 km/h | 65 km/h |
            | primary |          |                  | 60                | 65 km/h | 60 km/h |
            | primary | 15       | 60               |                   | 60 km/h | 23 km/h |
            | primary | 15       |                  | 60                | 23 km/h | 60 km/h |
            | primary | 15       | 30               | 60                | 34 km/h | 60 km/h |

    Scenario: Car - Maxspeed should not allow routing on unroutable ways
        Then routability should be
            | highway   | railway | access | maxspeed | maxspeed:forward | maxspeed:backward | bothw |
            | primary   |         |        |          |                  |                   | x     |
            | secondary |         | no     |          |                  |                   |       |
            | secondary |         | no     | 100      |                  |                   |       |
            | secondary |         | no     |          | 100              |                   |       |
            | secondary |         | no     |          |                  | 100               |       |
            | (nil)     | train   |        |          |                  |                   |       |
            | (nil)     | train   |        | 100      |                  |                   |       |
            | (nil)     | train   |        |          | 100              |                   |       |
            | (nil)     | train   |        |          |                  | 100               |       |
            | runway    |         |        |          |                  |                   |       |
            | runway    |         |        | 100      |                  |                   |       |
            | runway    |         |        |          | 100              |                   |       |
            | runway    |         |        |          |                  | 100               |       |
