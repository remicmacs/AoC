(require '[clojure.string :as str])

(defn code-to-mode
  [code]
  (if (= code "0") "position" "immediate")
)

(defn parse-opcode
  [opcode-str]
  "Parse a string to an opcode data structure"
  (let
      [
       padded (format "%05d" opcode-str)
       opcode (subs padded 3)
       param-1-mode (subs padded 2 3)
       param-2-mode (subs padded 1 2)
       param-3-mode (subs padded 0 1)
       ]
    (cond
      (= opcode "01")
      {
       :opcode "add"
       :param-nb 3
       :param-1-mode (code-to-mode param-1-mode)
       :param-2-mode (code-to-mode param-2-mode)
       }
      (= opcode "02")
      {
       :opcode "mul"
       :param-nb 3
       :param-1-mode (code-to-mode param-1-mode)
       :param-2-mode (code-to-mode param-2-mode)
       }
      (= opcode "03") {:opcode "inp" :param-nb 1}
      (= opcode "04") {
                       :opcode "out"
                       :param-nb 1
                       :param-1-mode (code-to-mode param-1-mode)
                       }
      (= opcode "05") {
                       :opcode "jit"
                       :param-nb 2
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)
                       }
      (= opcode "06") {
                       :opcode "jif"
                       :param-nb 2
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)
                       }
      (= opcode "07") {
                       :opcode "lth"
                       :param-nb 3
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)
                       }
      (= opcode "08") {
                       :opcode "eql"
                       :param-nb 3
                       :param-1-mode (code-to-mode param-1-mode)
                       :param-2-mode (code-to-mode param-2-mode)
                       }
      (= opcode "99") {:opcode "stp" :param-nb 0}
      )
    )
)

(defn exec-arithmetical-operation
  [program curpos opcode operator]
  (let
      [
       {
        mode1 :param-1-mode
        mode2 :param-2-mode
        } opcode
       dest-addr (get program (+ curpos 3))
       op-1 (if (= "position" mode1)
              (get program (get program (+ 1 curpos))) 
              (get program (+ 1 curpos)))
       op-2 (if (= "position" mode2)
              (get program (get program (+ 2 curpos))) 
              (get program (+ 2 curpos)))
       ]
    [
     (vec (concat 
           (subvec program 0 dest-addr)
           [(operator op-1 op-2 )]
           (subvec program (+ 1  dest-addr))))
     (+ curpos 4)
     ]
    )
)

(defn exec-add
  [program curpos opcode]
  (exec-arithmetical-operation program curpos opcode +)
)

(defn exec-mul
  [program curpos opcode]
  (exec-arithmetical-operation program curpos opcode *)
)

(defn exec-inp
  [program curpos opcode]
  (let 
      [
       dest-addr (get program (+ curpos 1))
       ]
    [
     (vec (concat 
           (subvec program 0 dest-addr)
           [(Integer/parseInt (read-line))]
           (subvec program (+ 1 dest-addr))))
     (+ curpos 2)
     ])
)

(defn exec-out
  [program curpos opcode]
  (let
      [
       {mode :param-1-mode} opcode
       val (if (= mode "position")
             (get program (get program (+ 1 curpos)))
             (get program (+ 1 curpos)))
       ]
    (println val))
  [
   program
   (+ curpos 2)
   ]
)

(defn exec-cond-jump
  [program curpos opcode operator]
  (let
      [
       {mode1 :param-1-mode mode2 :param-2-mode} opcode
       test (if (= mode1 "position")
             (get program (get program (+ 1 curpos)))
             (get program (+ 1 curpos)))
       newpos (if (= mode2 "position")
             (get program (get program (+ 2 curpos)))
             (get program (+ 2 curpos)))
       ]
    
    [
     program
     (if (operator 0 test) newpos (+ curpos 3))
     ]
    )
)

(defn exec-jit
  [program curpos opcode]
  (exec-cond-jump program curpos opcode not=)
)

(defn exec-jif
  [program curpos opcode]
  (exec-cond-jump program curpos opcode =)
)

(defn exec-test
  [program curpos opcode operator]
    (let
      [
       {
        mode1 :param-1-mode
        mode2 :param-2-mode
        } opcode
       dest-addr (get program (+ curpos 3))
       op-1 (if (= "position" mode1)
              (get program (get program (+ 1 curpos))) 
              (get program (+ 1 curpos)))
       op-2 (if (= "position" mode2)
              (get program (get program (+ 2 curpos))) 
              (get program (+ 2 curpos)))
       ]
    [
     (vec (concat 
           (subvec program 0 dest-addr)
           [(if (operator op-1 op-2) 1 0)]
           (subvec program (+ 1 dest-addr))))
     (+ curpos 4)
     ]
    )
)

(defn exec-lth
  [program curpos opcode]
  (exec-test program curpos opcode <)
)

(defn exec-eql
  [program curpos opcode]
  (exec-test program curpos opcode =)
)

(defn execute-instruction
  [program curpos]
  (if (= curpos -1)
    nil
      (let
        [
         parsed-opcode (parse-opcode (get program curpos))
         {opcode :opcode} parsed-opcode
         ]
      (cond
        (= opcode "add") 
        (let [[updated-prog newpos] (exec-add program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "mul")
        (let [[updated-prog newpos] (exec-mul program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "inp")
        (let [[updated-prog newpos] (exec-inp program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "out")
        (let [[updated-prog newpos] (exec-out program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "jit")
        (let [[updated-prog newpos] (exec-jit program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "jif")
        (let [[updated-prog newpos] (exec-jif program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "lth")
        (let [[updated-prog newpos] (exec-lth program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "eql")
        (let [[updated-prog newpos] (exec-eql program curpos parsed-opcode)]
          (execute-instruction updated-prog newpos))
        (= opcode "stp") [program -1])))
)

(defn execute-program
  [program]
  (execute-instruction program 0)
)

(def program 
  (vec 
   (map #(Integer/parseInt %) (str/split (str/trim (slurp "input.txt")) #","))))

(println "Running diagnostics on Intcode computer...")
(with-open [is (clojure.java.io/reader "./test-computer.code")]
  (binding [*in* is] (execute-program program)))

(println "Running diagnostics on thermal radiators...")
(with-open [is (clojure.java.io/reader "./test-radiators.code")]
  (binding [*in* is] (execute-program program)))
