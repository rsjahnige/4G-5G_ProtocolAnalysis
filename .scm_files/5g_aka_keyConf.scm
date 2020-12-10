(herald "5G AKA SUPI"
	(comment "Model for 5G AKA without the additional key confirmation round")
	)

(defmacro (AUTN sqn rand key)
  (cat (enc sqn (hash key rand)) (hash sqn rand key))
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

(defprotocol AKA5G basic

  (defrole UserEquip
    (vars (SUPI RAND n n2 data) (UE SN HN name) (SQN text))
    (trace
     (send (enc SUPI n (pubk HN)))
     (recv (cat RAND (AUTN SQN RAND (ltk UE HN))))
     (send (RES* RAND SN (ltk UE HN)))
     (recv (enc n2 (KSEAF RAND SN SQN (ltk UE HN))))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (uniq-gen n)
    (non-orig (ltk UE HN))
    (pen-non-orig SUPI SQN)
    )

  (defrole ServingNetwork
    (vars (SUPI RAND n n2 data) (UE SN HN name) (SQN text))
    (trace
     (recv (enc SUPI n (pubk HN)))
     (send (enc (cat (enc SUPI n (pubk HN)) SN) (ltk SN HN)))
     (recv (enc (cat RAND (AUTN SQN RAND (ltk UE HN)) (HXRES* RAND SN (ltk UE HN))) (ltk SN HN)))
     (send (cat RAND (AUTN SQN RAND (ltk UE HN)))) 
     (recv (RES* RAND SN (ltk UE HN)))
     (send (enc (RES* RAND SN (ltk UE HN)) (ltk SN HN)))
     (recv (enc (cat "Success" (KSEAF RAND SN SQN (ltk UE HN)) SUPI) (ltk SN HN)))
     (send (enc n2 (KSEAF RAND SN SQN (ltk UE HN))))
     )
    (non-orig (ltk SN HN))
    (uniq-gen n2)
    )

  (defrole HomeNetwork
    (vars (SUPI RAND n data) (UE SN HN name) (SQN text))
    (trace 
     (recv (enc (cat (enc SUPI n (pubk HN)) SN) (ltk SN HN)))
     (send (enc (cat RAND (AUTN SQN RAND (ltk UE HN)) (HXRES* RAND SN (ltk UE HN))) (ltk SN HN)))
     (recv (enc (RES* RAND SN (ltk UE HN)) (ltk SN HN)))
     (send (enc (cat "Success" (KSEAF RAND SN SQN (ltk UE HN)) SUPI) (ltk SN HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (uniq-gen RAND)
    (non-orig (ltk SN HN) (ltk UE HN) (privk HN))
    (pen-non-orig SUPI SQN)
    )
  )

(defskeleton AKA5G
  (vars (SUPI n data) (UE SN HN name) (SQN text))
  (defstrandmax UserEquip (SUPI SUPI) (UE UE) (SN SN) (HN HN) (SQN SQN) (n n))
  )

(defskeleton AKA5G
  (vars (SN HN name))
  (defstrandmax ServingNetwork (SN SN) (HN HN))
  )

(defskeleton AKA5G
  (vars (SUPI RAND data) (UE SN HN name) (SQN text))
  (defstrandmax HomeNetwork (SUPI SUPI) (RAND RAND) (UE UE) (SN SN) (HN HN) (SQN SQN))
  )
