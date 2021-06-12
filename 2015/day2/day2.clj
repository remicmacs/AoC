(require '[clojure.string :as str])

(defn dimensionToSurfaceArea
  "Convert a dimension object to surface area"
  [{w :width h :height l :length}]
  (
    let [
      topBottom (* 2 l w)
      leftRight (* 2 w h)
      behindBefore (* 2 h l)
      sorted (sort [l w h])
      margin (* (first sorted) (second sorted))
    ]
    (+ topBottom leftRight behindBefore margin)
  )
)

(defn dimensionToLength
  "Convert a dimension object to surface area"
  [{w :width h :height l :length}]
  (
    let [
      sorted (sort [l w h])
      a (first sorted)
      b (second sorted)
      perimeter (+ a a b b)
      volume (* w l h)
    ]
    (+ perimeter volume)
  )
)

(defn bulkProcessing
  [dimension]
  [(dimensionToSurfaceArea dimension) (dimensionToLength dimension)]
)

(defn toDimensions
  "Convert input line to box dimensions"
  [line]
  (
    let [
      [length, width, height] (str/split line #"x")
      iLength (Integer. length)
      iWidth (Integer. width)
      iHeight (Integer. height)
    ]
    (hash-map
      :length iLength
      :width iWidth
      :height iHeight
    )
  )
)

(def dimensions (map toDimensions(line-seq (java.io.BufferedReader. *in*))))
; Getting a matrix of n ((paper surface) (ribbon length))
(def matrix (map bulkProcessing dimensions))
; Rotating the matrix to get
;  ((list of wrapping paper surface needed)
;   (list of ribbon length needed))
; Clever trick
; from https://stackoverflow.com/questions/8314789/rotate-a-list-of-list-matrix-in-clojure
(def rotated (apply map list matrix))
(println (str "Wrapping paper in sqft : " (reduce + 0 (first rotated))))
(println (str "Ribbon in ft : " (reduce + 0 (second rotated))))