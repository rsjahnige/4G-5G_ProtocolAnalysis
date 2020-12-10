(herald "5G AKA SUPI"
	(algebra diffie-hellman)
	(comment "Model for 5G AKA with SQN_UE modeled as a randomly generated shard secret and SUCI modeled using Diffie-Hellman algebra")
	)

(defmacro (MAC ciphertext symkey)
  (hash ciphertext (hash (hash symkey)))
  )

(defmacro (SUCI pubk_UE symkey supi)
  (cat pubk_UE (enc supi (hash symkey)) (MAC (enc supi (hash symkey)) symkey)) ; Public key of UE || SUPI encrypted under randomly derived symmetric key || MAC 
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

(defprotocol AKA5G diffie-hellman

  (defrole user-init
    (vars (SQN_UE data) (Y_hn base) (UE HN name))
    (trace
     (recv (enc SQN_UE Y_hn UE (ltk UE HN)))
     (init (cat "User" SQN_UE Y_hn UE HN)) 
     )
    (pen-non-orig SQN_UE)
    )

  (defrole home-init
    (vars (SQN_UE SQN_HN data) (UE HN name) (X_hn expn))
    (trace
     (init (cat "Home" SQN_HN X_hn UE HN))
     (send (enc SQN_UE (exp (gen) X_hn) UE (ltk UE HN)))
     )
    (fn-of ("SQN" (SQN_HN (hash "1" SQN_UE)))) ; sequence number of home network
    (lt (SQN_UE SQN_HN)) ; SQN_UE < SQN_HN
    (pen-non-orig SQN_UE SQN_HN)
    (uniq-gen SQN_UE)
    (non-orig X_hn) ; private key of home network
    )

  ;(defrole mal_gNB
  ;  (vars (SQN_UE SQN_HN RAND n data) (UE SN HN name) (SUPI text))
  ;  (trace
  ;   (recv (enc SUPI SQN_UE n (pubk HN)))
  ;   (send (cat RAND (AUTN SQN_HN RAND (ltk UE HN))))
  ;   (recv (RES* RAND SN (ltk UE HN)))
  ;   (send (RES* RAND SN (ltk UE HN)))
  ;   )
  ;  )
  
  (defrole UserEquip
    (vars (Y_hn base) (X_ue rndx) (RAND SQN_UE SQN_HN data) (UE SN HN name) (SUPI text))
    (trace
     (obsv (cat "User" SQN_UE Y_hn UE HN))
     (send (SUCI (exp (gen) X_ue) (exp Y_hn X_ue) SUPI))
     (recv (cat RAND (AUTN SQN_HN RAND (ltk UE HN))))
     (send (RES* RAND SN (ltk UE HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (uniq-gen X_ue)
    (non-orig (ltk UE HN) X_ue)
    (pen-non-orig SQN_UE SQN_HN SUPI)
    )

  (defrole ServingNetwork
    (vars (Y_ue Y_hn base) (X_ue expn) (SQN_HN RAND data) (UE SN HN name) (SUPI text))
    (trace
     (recv (SUCI Y_ue (exp Y_hn X_ue) SUPI))
     (send (enc (SUCI Y_ue (exp Y_hn X_ue) SUPI) SN (ltk SN HN)))
     (recv (enc (cat RAND (AUTN SQN_HN RAND (ltk UE HN)) (HXRES* RAND SN (ltk UE HN))) (ltk SN HN)))
     (send (cat RAND (AUTN SQN_HN RAND (ltk UE HN)))) 
     (recv (RES* RAND SN (ltk UE HN)))
     (send (enc (RES* RAND SN (ltk UE HN)) (ltk SN HN)))
     (recv (enc (cat "Success" (KSEAF RAND SN SQN_HN (ltk UE HN)) SUPI) (ltk SN HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (non-orig (ltk SN HN))
    (pen-non-orig SUPI)
    )

  (defrole HomeNetwork
    (vars (Y_ue base) (X_hn expn) (SQN_UE SQN_HN RAND data) (UE SN HN name) (SUPI text))
    (trace
     (obsv (cat "Home" SQN_HN X_hn UE HN))
     (recv (enc (SUCI Y_ue (exp Y_ue X_hn) SUPI) SN (ltk SN HN)))
     (send (enc (cat RAND (AUTN SQN_HN RAND (ltk UE HN)) (HXRES* RAND SN (ltk UE HN))) (ltk SN HN)))
     (recv (enc (RES* RAND SN (ltk UE HN)) (ltk SN HN)))
     (send (enc (cat "Success" (KSEAF RAND SN SQN_HN (ltk UE HN)) SUPI) (ltk SN HN)))
     )
    (fn-of ("ID" (SUPI (cat UE HN))))
    (uniq-gen RAND)
    (non-orig (ltk SN HN) (ltk UE HN) X_hn)
    (pen-non-orig SQN_HN SUPI)
    )
  )

;(defskeleton AKA5G
;  (vars (Y_hn base) (UE HN name) (SUPI text))
;  (defstrandmax UserEquip (Y_hn Y_hn) (SUPI SUPI) (UE UE) (HN HN))
;  ;(defstrandmax mal_gNB)
;  )

(defskeleton AKA5G
  (vars (SN HN name))
  (defstrandmax ServingNetwork (SN SN) (HN HN))
  )

(defskeleton AKA5G
  (vars (RAND data) (X_hn expn) (UE SN HN name) (SUPI text))
  (defstrandmax HomeNetwork (SUPI SUPI) (X_hn X_hn) (RAND RAND) (UE UE) (SN SN) (HN HN))
  )
