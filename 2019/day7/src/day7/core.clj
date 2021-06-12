(ns day7.core
  (:gen-class)
  (:require [clojure.math.combinatorics :as combo]))

(require '[clojure.string :as str])

(defn code-to-mode
  [code]
  (if (= code "0") "position" "immediate")
)

(defn parse-opcode
  [opcode]
  "Parse an integer code to an opcode data structure"
  (let
      [
       padded (format "%05d" opcode)
       opcode (subs padded 3)
       param-1-mode (subs padded 2 3)
       param-2-mode (subs padded 1 2)
       param-3-mode (subs padded 0 1)
       ]
    (cond
      (= opcode "01") {:opcode "add"
                       :param-nb 3
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)}
      (= opcode "02") {:opcode "mul"
                       :param-nb 3
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)}
      (= opcode "03") {:opcode "inp" :param-nb 1}
      (= opcode "04") {:opcode "out"
                       :param-nb 1
                       :param-1-mode (code-to-mode param-1-mode)}
      (= opcode "05") {:opcode "jit"
                       :param-nb 2
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)}
      (= opcode "06") {:opcode "jif"
                       :param-nb 2
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)}
      (= opcode "07") {:opcode "lth"
                       :param-nb 3
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)}
      (= opcode "08") {:opcode "eql"
                       :param-nb 3
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)}
      (= opcode "99") {:opcode "stp" :param-nb 0})))

(defn exec-arithmetical-operation
  [operator opcode proc-state]
  (let
      [
       program (:memory proc-state)
       curpos (:cursor proc-state)
       {mode1 :param-1-mode
        mode2 :param-2-mode} opcode
       dest-addr (get program (+ curpos 3))
       op-1 (if (= "position" mode1)
              (get program (get program (+ 1 curpos))) 
              (get program (+ 1 curpos)))
       op-2 (if (= "position" mode2)
              (get program (get program (+ 2 curpos))) 
              (get program (+ 2 curpos)))
       ]
    (assoc
     proc-state
     :memory (vec (concat 
           (subvec program 0 dest-addr)
           [(operator op-1 op-2 )]
           (subvec program (+ 1  dest-addr))))
     :cursor (+ curpos 4))))

(defn exec-inp
  [opcode proc-state]
  (let 
      [
       program (:memory proc-state)
       curpos (:cursor proc-state)
       input-list (:in proc-state)
       dest-addr (get program (+ curpos 1))]
    (assoc proc-state 
           :memory (vec (concat
                         (subvec program 0 dest-addr)
                         [(first input-list)]
                         (subvec program (+ 1 dest-addr))))
           :cursor (+ curpos 2)
           :in (rest input-list))))

(defn exec-out
  [opcode proc-state]
  (let
      [
       program (:memory proc-state)
       curpos (:cursor proc-state)
       {mode :param-1-mode} opcode
       val (if (= mode "position")
             (get program (get program (+ 1 curpos)))
             (get program (+ 1 curpos)))
       ]
    (assoc proc-state :cursor (+ curpos 2) :out (vec (conj (:out proc-state) val)) )))

(defn exec-cond-jump
  [operator opcode proc-state]
  (let
      [
       program (:memory proc-state)
       curpos (:cursor proc-state)
       {mode1 :param-1-mode mode2 :param-2-mode} opcode
       test (if (= mode1 "position")
             (get program (get program (+ 1 curpos)))
             (get program (+ 1 curpos)))
       newpos (if (= mode2 "position")
             (get program (get program (+ 2 curpos)))
             (get program (+ 2 curpos)))
       ]
    (assoc proc-state :cursor (if (operator 0 test) newpos (+ curpos 3)))))

(defn exec-test
  [operator opcode proc-state]
    (let
      [
       program (:memory proc-state)
       curpos (:cursor proc-state)
       {mode1 :param-1-mode
        mode2 :param-2-mode} opcode
       dest-addr (get program (+ curpos 3))
       op-1 (if (= "position" mode1)
              (get program (get program (+ 1 curpos))) 
              (get program (+ 1 curpos)))
       op-2 (if (= "position" mode2)
              (get program (get program (+ 2 curpos))) 
              (get program (+ 2 curpos)))
       ]
      (assoc proc-state 
             :memory (vec (concat
                           (subvec program 0 dest-addr)
                           [(if (operator op-1 op-2) 1 0)]
                           (subvec program (+ 1 dest-addr))))
             :cursor (+ curpos 4))))

(defn exec-stp
  [proc-state]
  (assoc proc-state :cursor -1))

(defn step
  [proc-state]
  (if (= (:cursor proc-state) -1)
    nil
      (let
        [
         parsed-opcode (parse-opcode
                        (get (:memory proc-state) (:cursor proc-state)))
         {opcode :opcode} parsed-opcode
         operation (get
                    {
                     "add" (partial exec-arithmetical-operation + parsed-opcode)
                     "mul" (partial exec-arithmetical-operation * parsed-opcode)
                     "inp" (partial exec-inp parsed-opcode)
                     "out" (partial exec-out parsed-opcode)
                     "jit" (partial exec-cond-jump not= parsed-opcode)
                     "jif" (partial exec-cond-jump = parsed-opcode)
                     "lth" (partial exec-test < parsed-opcode)
                     "eql" (partial exec-test = parsed-opcode)
                     "stp" exec-stp
                     }
                    opcode) 
         ]
        (operation proc-state))))

(defn run-process
  [proc-state]
  (loop
      [state proc-state]
    (if (= (:cursor state) -1)
      state
      (let
          [newstate (step state)]
        (recur newstate)))))

(defn pipe
  [process in]
  (let [
        oldin (:in process)
        output (first (:out (run-process (assoc process :in (vec (conj oldin in))))))]
    output))

(defn init-processes
  [program permutation]
  (for [id permutation]
    {:id id
     :memory program
     :cursor 0
     :in [id]
     :out []}))

(defn permutation-to-value
  [program permutation]
  (let 
      [processes (init-processes program permutation)]
    (pipe
     (nth processes 4)
     (pipe
      (nth processes 3)
      (pipe
       (nth processes 2)
       (pipe
        (nth processes 1)
        (pipe
         (nth processes 0) 0)))))))

(defn find-max-output-signal
  [program]
  (let [perms-to-test (combo/permutations [0 1 2 3 4])
        sequence-to-val 
        (reduce
         (fn
           [newmap perm]
           (assoc
            newmap
            perm
            (permutation-to-value program perm)))
         {} perms-to-test)]
    (apply max-key val sequence-to-val)))

(defn -main
  [& args]

  (def program 
    (vec 
     (map #(Integer/parseInt %) (str/split (str/trim (slurp "program.txt")) #","))))
  (find-max-output-signal program)
)
