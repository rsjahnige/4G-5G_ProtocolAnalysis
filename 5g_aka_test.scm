(herald "5G AKA Round 1 suci "
	(comment "First attempt for modeling 5G AKA")
	)

;;macro for AUTN
(defmacro (AUTN sqn rand key)
  (cat (hash sqn (hash key rand)) (hash sqn rand key))
    )

(defmacro (RES* rand sname key)
  (hash (cat (hash key rand) (hash key rand)) sname rand (hash key rand))
    )

(defmacro (HRES* rand sname key)
  (hash (RES* rand sname key) rand)
    )

(defmacro (XRES* rand sname key)
  (hash (cat (hash key rand) (hash key rand)) sname rand (hash key rand))
    )

(defmacro (HXRES* rand sname key)
  (hash (XRES* rand sname key) rand)
    )

(defmacro (KAUSF rand sname sqn key)
  (hash (cat (hash key rand) (hash key rand)) sname (hash sqn (hash key rand)))
  )

(defmacro (KSEAF rand sname sqn key)
  (hash (KAUSF rand sname sqn key) sname)
  )

;;Protocol 5G-AKA 
(defprotocol AKA5G basic

  (defrole UserEquip
    (vars (SUPI RAND data) (UE SN HN name) (SQN text))
    (trace
     (send (enc SUPI (pubk HN)))
     (recv (cat RAND (AUTN SQN RAND (ltk UE HN))))
     (send (RES* RAND SN (ltk UE HN)))
     )
    (non-orig (ltk UE HN))
    )

  (defrole ServingNetwork
    (vars (SUPI RAND data) (UE SN HN name) (SQN text))
    (trace
     (recv (enc SUPI (pubk HN)))
     (send (cat (enc SUPI (pubk HN) SN)))
     (recv (cat RAND (AUTN SQN RAND (ltk UE HN)) (HXRES* RAND SN (ltk UE HN))))
     (send (cat RAND (AUTN SQN RAND (ltk UE HN)))) ;; ngKSI, AMF, and ABBA need to be added???
     (recv (RES* RAND SN (ltk UE HN)))
     (send (RES* RAND SN (ltk UE HN)))
     (recv (cat "Success" (KSEAF RAND SN SQN (ltk UE HN)) SUPI))
     )
    (non-orig SQN (ltk UE HN))
    )

  (defrole HomeNetwork
    (vars (SUPI RAND data) (UE SN HN name) (SQN text))
    (trace 
     (recv (cat (enc SUPI (pubk HN) SN)))
     (init (cat (XRES* RAND SN (ltk UE HN)) SUPI)) ;;store XRES* and SUPI
     (send (cat RAND (AUTN SQN RAND (ltk UE HN)) (HXRES* RAND SN (ltk UE HN))))
     (recv (RES* RAND SN (ltk UE HN)))
     (send (cat "Success" (KSEAF RAND SN SQN (ltk UE HN)) SUPI))
     )
    (uniq-gen RAND)
    (non-orig SQN (ltk UE HN))
    )
  )

(defskeleton AKA5G
  (vars (SUPI data) (UE HN name) (SQN text))
  (defstrand UserEquip 3 (SUPI SUPI) (UE UE) (HN HN) (SQN SQN))
  )

(defskeleton AKA5G
  (vars (SN name))
  (defstrand ServingNetwork 7  (SN SN))
  )

(defskeleton AKA5G
  (vars (SUPI RAND data) (UE HN name) (SQN text))
  (defstrand HomeNetwork 4 (SUPI SUPI) (RAND RAND) (UE UE) (HN HN))
  )