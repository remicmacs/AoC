; reading one line from stdin
(def lines (read-line))

(defn nextOp
  "Simply find the end position (part 1)"
  [curFloor, op] (
  if (= op \)) (dec curFloor) (inc curFloor)
))

(defn posBasement
  "Find the end position in floor nb
  and the index of the first floor to lead to the basement"
  [[index, firstBasement, curFloor], op] (
  if (= op \))
    [
      (inc index),
      ; Check if the position of first passing through basement has been found
      (if (and (= firstBasement -1) (= curFloor 0))
        index
        firstBasement
      ),
      (dec curFloor)
    ]
    [(inc index), firstBasement, (inc curFloor)]
))

(println (reduce
          posBasement
          [1, -1, 0]
          lines))
