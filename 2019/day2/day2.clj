(require '[clojure.string :as str])

(defn mutate-program
  [program pos]
  (let
    [
      op-code (get program pos)
      ptr-op-1 (get program (+ pos 1))
      ptr-op-2 (get program (+ pos 2))
      ptr-dest (get program (+ pos 3))
      op-1 (get program ptr-op-1)
      op-2 (get program ptr-op-2)
    ]
    (if (= op-code 1)
      (vec (concat
        (subvec program 0 ptr-dest)
        [(+ op-1 op-2)]
        (subvec program (+ ptr-dest 1))))
      (vec (concat
        (subvec program 0 ptr-dest)
        [(* op-1 op-2)]
        (subvec program (+ ptr-dest 1))))
    ))
  )

(defn compute
  [program pos]
  (let
    [op-code (get program pos)]
    (cond
      (= op-code 99) program
      (or (= op-code 1) (= op-code 2))
        (let [mutated-program (mutate-program program pos)]
          (compute mutated-program (+ pos 4)))
      :else (do (println "Fatal error"))
    ))
)

(defn initialize
  "Initialize the program with the provided params"
  [orig-program noun verb]
  (vec (concat
    [(get orig-program 0)]
    [noun verb]
    (subvec orig-program 3)))
)

(defn find-values
  "Find the two initial params for a last result 19690720"
  [original]
  (let
    [target 19690720]
    (loop
      [
        a 0
        b 0
      ]
      (if
        (= (get (compute (initialize original a b) 0) 0) target)
        [a b]
        (if
          (= a 99)
          (recur 0 (inc b))
          (recur (inc a) b))
        )
      )
    )
  )


(def
  init-program (vec (map #(. Integer parseInt %) (str/split (read-line) #","))))
(def final-state (compute (initialize init-program 12 2) 0))
(println (get final-state 0))

(println (find-values init-program))
