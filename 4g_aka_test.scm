(herald "4G AKA Round 1 suci "
	(comment "First attempt for modeling 4G ePs-AKA")
	)

;;macro for AUTN
(defmacro (AUTN sqn rand key)
  (cat (hash sqn (hash key rand)) (hash sqn rand key))
    )

(defmacro (RES rand sname key)
  (hash (cat (hash key rand) (hash key rand)) sname rand (hash key rand))
    )

(defmacro (XRES rand sname key)
  (hash (cat (hash key rand) (hash key rand)) sname rand (hash key rand))
    )

(defmacro (KASME rand sname sqn key)
  (hash (cat (hash key rand) (hash key rand)) sname (hash sqn (hash key rand)))
  )


;;Protocol 4G-EPSAKA 
(defprotocol AKA4G basic

  (defrole UserEquip
    (vars (SUPI RAND data) (UE SN HN name) (SQN text))
    (trace
     (send SUPI) ;; IMSI in 4g
     (recv (cat RAND (AUTN SQN RAND (ltk UE HN))))
     (send (RES RAND SN (ltk UE HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (non-orig (ltk UE HN) SQN)
    )

  (defrole ServingNetwork
    (vars (SUPI RAND data) (UE SN HN name) (SQN text))
    (trace
     (recv SUPI)
     (send (enc (cat SUPI SN) (ltk SN HN)))
     (recv (enc (cat RAND (AUTN SQN RAND (ltk UE HN)) (XRES RAND SN (ltk UE HN)) (KASME RAND SN SQN (ltk UE HN))) (ltk SN HN)))
     (send (cat RAND (AUTN SQN RAND (ltk UE HN)))) ;; ngKSI, AMF, and ABBA need to be added???
     (recv (RES RAND SN (ltk UE HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (non-orig (ltk SN HN))
    )

  (defrole HomeNetwork
    (vars (SUPI RAND data) (UE SN HN name) (SQN text))
    (trace 
    (recv (enc (cat SUPI SN) (ltk SN HN)))
     ;;(init (cat (XRES RAND SN (ltk UE HN)) SUPI)) ;;store XRES* and SUPI
     (send (enc (cat RAND (AUTN SQN RAND (ltk UE HN)) (XRES RAND SN (ltk UE HN)) (KASME RAND SN SQN (ltk UE HN))) (ltk SN HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (uniq-gen RAND)
    (non-orig SQN (ltk SN HN) (ltk UE HN))
    )
  )

(defskeleton AKA4G
  (vars (SUPI data) (UE SN HN name) (SQN text))
  (defstrandmax UserEquip (SUPI SUPI) (UE UE) (HN HN) (SN SN) (SQN SQN))
  (deflistner SUPI)
  )

(defskeleton AKA4G
  (vars (SUPI data) (SN HN name))
  (defstrandmax ServingNetwork (SN SN) (HN HN) (SUPI SUPI))
  )

(defskeleton AKA4G
  (vars (SUPI RAND data) (UE SN HN name) (SQN text))
  (defstrandmax HomeNetwork (SUPI SUPI) (RAND RAND) (UE UE) (SN SN) (HN HN) (SQN SQN))
  )
