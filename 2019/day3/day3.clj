(require '[clojure.string :as str])
(require '[clojure.set :as set])

(defn increment-pos
  [pos instruction]
  (let
    [
      [direction norm] instruction
      [x y] pos
    ]
    (cond
      (= direction "R")
        [(+ x norm) y]
      (= direction "L")
        [(- x norm) y]
      (= direction "U")
        [x (+ y norm)]
      (= direction "D")
        [x (- y norm)]
    )
    ))

(defn path-to-newpos
  [pos instruction]
  (let
    [
      [direction norm] instruction
      [x y] pos
    ]
    (cond
      (= direction "R")
        (map #(-> [% y]) (range (+ 1 x) (+ 1 (+ x norm))))
      (= direction "L")
        (map #(-> [% y]) (range (- x 1) (- x norm 1) -1))
      (= direction "U")
        (map #(-> [x %]) (range (+ 1 y) (+ 1 (+ y norm))))
      (= direction "D")
        (map #(-> [x %]) (range (- y 1) (- y norm 1) -1))
    )
  )
  )

(defn unpack-instruction
  [instruction]
  (let
    ; The direction is the first char of the instruction string
    [direction (subs instruction 0 1)
    ; The rest is the length to go in that direction
    norm (Integer/parseInt (subs instruction 1))]
    [direction norm]
  ))

(defn pull-wire
  "Given an instruction array [direction norm]
  and an initial position return the new position and a vector of
  all the coordinates crossed by the wire"
  [instruction pos]
  ; Trick because sometimes it'll happen
  (if (nil? instruction) [pos []]
    [(increment-pos pos instruction) (path-to-newpos pos instruction)]
    )
)

(defn exec-step
  "Execute one round of the wire pulling process"
  [inss maps poss]
  (let
    [
      [pos1 pos2] poss
      [ins1 ins2] inss
      [map1 map2] maps
      [newpos1 new-wire1] (pull-wire (unpack-instruction ins1) pos1)
      [newpos2 new-wire2] (pull-wire (unpack-instruction ins2) pos2)
    ]
    {
      :maps [(set/union map1 (set new-wire1)) (set/union map2 (set new-wire2))]
      :positions [newpos1 newpos2]
    }
  ))

(defn create-maps
  "Pull the two wires and get the set of coordinates crossed by each wire"
  [wire1 wire2 acc]
  (if
    (and (empty? wire1) (empty? wire2))
    acc
    (let
      [
        {maps :maps poss :positions} acc
        newacc (exec-step [(first wire1) (first wire2)] maps poss)
      ]
      (create-maps (rest wire1) (rest wire2) newacc)
      )
    )
  )

(defn process-input
  "Wrapper function to first call of create-maps function"
  [wire1 wire2]
  (
    let
    [
      init-maps [(set []) (set [])]
      init-pos [[0 0] [0 0]]
    ]
    (create-maps wire1 wire2 {:maps init-maps :positions init-pos})
  ))

(defn intersection-to-distance
  [intersection]
  (let [
    [x y] (map #(Math/abs %) intersection)
    ]
  (+ x y)
  )
)

(defn add-step
  [target steps acc]
  (let [[pos total] acc]
    (if (or (= target pos) (empty? steps))
      [pos total]
      (let
        [
          [step & rest-steps] steps
        ]
        (add-step
          target rest-steps
          [
            step
            (inc total)
          ]
        )
      )
    )
  )
)

(defn add-steps
  [target wire acc]
  (let
    [
      [pos total] acc
      [current-instruction & rest-wire] wire
      instruction (unpack-instruction current-instruction)
      [newpos newtotal] (add-step target (path-to-newpos pos instruction) acc)
    ]
    (if (= target pos)
      total
      (add-steps target rest-wire [newpos newtotal])
    )
  )
)

(defn intersection-to-steps
  [intersection wire]
  (add-steps intersection wire [[0 0] 0])
)

(defn intersection-to-total-steps
  [intersection wire1 wire2]
  (+
    (intersection-to-steps intersection wire1)
    (intersection-to-steps intersection wire2)
  )
  )

(def wire1 (str/split (read-line) #","))
(def wire2 (str/split (read-line) #","))
(def result (process-input wire1 wire2))

(let [
  {maps :maps} result
  [map1 map2] maps
  intersections (set/intersection map1 map2)
  ]
  (println (apply min (map intersection-to-distance intersections)))
  (println (apply min (map #(intersection-to-total-steps % wire1 wire2) intersections)))
)