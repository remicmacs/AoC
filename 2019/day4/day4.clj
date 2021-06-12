(require '[clojure.string :as str])

(defn not-decreasing-numbers
  [candidate prev-char]
  (if (empty? candidate)
    true
    (if (empty? prev-char)
      (not-decreasing-numbers (subs candidate 1) (subs candidate 0 1))
      (and
        (<=
          (Integer/parseInt prev-char)
          (Integer/parseInt (subs candidate 0 1))
        )
        (not-decreasing-numbers (subs candidate 1) (subs candidate 0 1))
      )
    )
  )
)

(defn has-double
  [candidate]
  (or
    (.contains candidate "00")
    (.contains candidate "11")
    (.contains candidate "22")
    (.contains candidate "33")
    (.contains candidate "44")
    (.contains candidate "55")
    (.contains candidate "66")
    (.contains candidate "77")
    (.contains candidate "88")
    (.contains candidate "99")
  )
)

(defn triml-char
  [candidate remove]
  (cond
    (empty? candidate) candidate
    (= (subs candidate 0 1) remove) (triml-char (subs candidate 1) remove)
    :else candidate
  )
)

(defn has-double-but-no-more
  [candidate]
  (cond
    (< (count candidate) 1) false
    (= (count candidate) 2)
      (= (subs candidate 0 1) (subs candidate 1 2))
    (>= (count candidate) 3)
      (or
        (and
          (= (subs candidate 0 1) (subs candidate 1 2))
          (not (= (subs candidate 1 2) (subs candidate 2 3)))
        )
        (or
          (and
            (not (= (subs candidate 0 1) (subs candidate 1 2)))
            (has-double-but-no-more (subs candidate 1))
          )
          (has-double-but-no-more (triml-char candidate (subs candidate 0 1)))
        )
      )
  )
)

(defn check-new-criteria
  [candidate]
  (and
    (not-decreasing-numbers candidate "")
    (has-double-but-no-more candidate)
  )
)

(defn check-criteria
  [candidate]
  (and
    (not-decreasing-numbers candidate "")
    (has-double candidate)
  )
)

(def target-range
  (map str (apply range
    (map #(Integer/parseInt %) (str/split (read-line) #"-")))))
(def filtered (filter check-criteria target-range))
(println (count filtered))
(def new-filtered (filter check-new-criteria target-range))
(println (count new-filtered))