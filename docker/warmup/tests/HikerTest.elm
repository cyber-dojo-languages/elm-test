module HikerTest exposing (suite)

import Expect
import Hiker
import Test exposing (Test, test)


suite : Test
suite =
    test "to life the universe and everything" <|
        \_ ->
            Hiker.answer
                |> Expect.equal 42
