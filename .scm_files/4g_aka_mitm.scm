(herald "4G AKA SUCI"
	(comment "First attempt for modeling 4G ePs-AKA")
	)

;;macro for AUTN
(defmacro (AUTN sqn rand key)
  (cat (enc sqn (hash key rand)) (hash sqn rand key))
    )

(defmacro (RES rand sname key)
  (hash (hash key rand) (hash key rand) sname rand (hash key rand))
    )

(defmacro (XRES rand sname key)
  (hash (hash key rand) (hash key rand) sname rand (hash key rand))
    )

(defmacro (KASME rand sname sqn key)
  (hash (hash key rand) (hash key rand) sname (hash sqn (hash key rand)))
  )


;;Protocol 4G-EPSAKA 
(defprotocol AKA4G basic

  (defrole malSN
    (vars (SQN RAND data) (UE SN HN name) (IMSI text))
    (trace
     (recv IMSI)
     (send (cat RAND (AUTN SQN RAND (ltk UE HN))))
     (recv (RES RAND SN (ltk UE HN)))
     (send (RES RAND SN (ltk UE HN)))
     )
    (deflistener IMSI)
    (deflistener (cat RAND (AUTH SQN RAND (ltk UE HN))))
    )
  
  (defrole UserEquip
    (vars (SQN RAND data) (UE SN HN name) (IMSI text))
    (trace
     (send IMSI) 
     (recv (cat RAND (AUTN SQN RAND (ltk UE HN))))
     (send (RES RAND SN (ltk UE HN)))
     )
    (fn-of ("ID" (IMSI (cat UE HN))))
    (non-orig (ltk UE HN))
    )

  (defrole ServingNetwork
    (vars (SQN RAND data) (UE SN HN name) (IMSI text))
    (trace
     (recv IMSI)
     (send (enc IMSI SN (ltk SN HN)))
     (recv (enc (cat RAND (AUTN SQN RAND (ltk UE HN)) (XRES RAND SN (ltk UE HN)) (KASME RAND SN SQN (ltk UE HN))) (ltk SN HN)))
     (send (cat RAND (AUTN SQN RAND (ltk UE HN)))) 
     (recv (RES RAND SN (ltk UE HN)))
     )
    (non-orig (ltk SN HN))
    )

  (defrole HomeNetwork
    (vars (SQN RAND data) (UE SN HN name) (IMSI text))
    (trace 
     (recv (enc IMSI SN (ltk SN HN)))
     (send (enc (cat RAND (AUTN SQN RAND (ltk UE HN)) (XRES RAND SN (ltk UE HN)) (KASME RAND SN SQN (ltk UE HN))) (ltk SN HN)))
     )
    (fn-of ("ID" (IMSI (cat UE HN))))
    (uniq-gen RAND)
    (non-orig (ltk SN HN) (ltk UE HN))
    )
  )

(defskeleton AKA4G
  (vars (SQN data) (UE SN HN name) (IMSI text))
  (defstrandmax UserEquip (IMSI IMSI) (UE UE) (HN HN) (SN SN) (SQN SQN))
  (defstrandmax malSN)
  )

(defskeleton AKA4G
  (vars (SN HN name))
  (defstrandmax ServingNetwork (SN SN) (HN HN))
  )

(defskeleton AKA4G
  (vars (SQN RAND data) (UE SN HN name) (IMSI text))
  (defstrandmax HomeNetwork (IMSI IMSI) (RAND RAND) (UE UE) (SN SN) (HN HN) (SQN SQN))
  )
