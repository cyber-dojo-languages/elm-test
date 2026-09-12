module ExpectAssertions exposing (suite)

import Expect exposing (FloatingPointTolerance(..))
import Set
import Test exposing (Test, describe, test)


{-| The assertions elm-explorations/test gives you to write tests with.

Every one of these is made against literals rather than against Hiker, so this
module goes on passing while you rewrite everything around it. It is here to
show you the vocabulary, not to test the kata.

-}
suite : Test
suite =
    describe "expect_assertions"
        [ test "equal" <|
            \_ -> 5 - 4 |> Expect.equal 1
        , test "notEqual" <|
            \_ -> 5 - 3 |> Expect.notEqual 1
        , test "lessThan" <|
            \_ -> 4 |> Expect.lessThan 5
        , test "greaterThan" <|
            \_ -> 5 |> Expect.greaterThan 4
        , test "atMost" <|
            \_ -> 4 |> Expect.atMost 4
        , test "atLeast" <|
            \_ -> 4 |> Expect.atLeast 4
        , test "within" <|
            \_ -> 1.0e-7 |> Expect.within (Absolute 1.0e-6) 0.0
        , test "ok" <|
            \_ -> Ok 42 |> Expect.ok
        , test "err" <|
            \_ -> Err "no tea" |> Expect.err
        , test "equalLists" <|
            \_ -> [ 1, 2 ] |> Expect.equalLists [ 1, 2 ]
        , test "equalSets" <|
            \_ -> Set.fromList [ 1, 2 ] |> Expect.equalSets (Set.fromList [ 1, 2 ])
        , test "all" <|
            \_ -> 42 |> Expect.all [ Expect.greaterThan 0, Expect.lessThan 100 ]
        ]
