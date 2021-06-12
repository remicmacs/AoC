(require '[clojure.string :as str])

(defn swap-kv
  [[key val]]
  [val key]
)

(def orbits
  (map #(swap-kv %) 
          (map #(str/split % #"\)") (line-seq (java.io.BufferedReader. *in*)))))

(def orbits-map (apply hash-map (flatten orbits)))

(defn count-orbits
  [orbits-map object]
  (if (contains? orbits-map object)
    (+ 1 (count-orbits orbits-map (orbits-map object)))
    0
    )
)
(defn find-ancestors
  [orbits-map child]
  (if (contains? orbits-map child)
    (concat [child] (find-ancestors orbits-map (orbits-map child)))
    [child])
)

(defn in?
  [coll elm]
  (some #(= elm %) coll)
)

(defn steps-to-target
  [orbits-map start target]
  (if (= start target)
    0
    (+ 1 (steps-to-target orbits-map (orbits-map start) target))
    )
)

(defn find-closest-common-ancestor
  [orbits-map a b]
  (loop
      [
       a-ancestors (rest (find-ancestors orbits-map a))
       b-ancestors (rest (find-ancestors orbits-map b))
       ]
    (cond
      (not (in? a-ancestors (first b-ancestors)))
      (recur a-ancestors (rest b-ancestors))
      (not (in? b-ancestors (first a-ancestors)))
      (recur (rest a-ancestors) b-ancestors)
      :else (first a-ancestors)
      )
    )
)

(println (reduce + (map #(count-orbits orbits-map %) (keys orbits-map))))
(def pivot (find-closest-common-ancestor orbits-map "YOU" "SAN"))
(println (- (+ (steps-to-target orbits-map "SAN" pivot) 
             (steps-to-target orbits-map "YOU" pivot))
            2
            ))
