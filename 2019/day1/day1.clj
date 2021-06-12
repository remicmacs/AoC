(def weights
  (map #(. Integer parseInt %) (line-seq (java.io.BufferedReader. *in*))))

(defn weight-to-fuel
  [weight]
  (- (int (Math/floor (/ weight 3))) 2))

(defn weight-to-fuel
  [payload]
  (let [fuel (- (int (Math/floor (/ payload 3))) 2)]
    (if (<= fuel 0)
      0
      (+ fuel (weight-to-fuel fuel))
    ))
)

(def fuels (map weight-to-fuel weights))
(println fuels)
(println (reduce + 0 fuels))