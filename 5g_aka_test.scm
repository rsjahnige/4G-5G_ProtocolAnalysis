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

  (defrole UE
    (vars (supi RAND data) (homename servername name) (SQN text) (key skey))
    (trace
        (send (enc supi (pubk homename)))
        (recv (cat RAND (AUTN SQN RAND key)))
        (send (RES* RAND servername key) )


     )
    )

  (defrole ServingNetwork
    (vars (supi RAND data) (homename servername name) (SQN text) (key skey))
    (trace
        (recv (enc supi (pubk homename)))
        (send (cat (enc supi (pubk homename) servername)))
        (recv (cat RAND (AUTN SQN RAND key) (HXRES* RAND servername key)))
        (send (cat RAND (AUTN SQN RAND key))) ;; ngKSI, AMF, and ABBA need to be added???
        (send (RES* RAND servername key))
        (recv (cat (KSEAF RAND servername SQN key) supi))
    )
    (non-orig SQN key)
   )

   (defrole HomeNetwork
    (vars (supi RAND data) (homename servername name) (SQN text) (key skey))
    (trace 
        (recv (cat (enc supi (pubk homename) servername)))
        (init (cat (XRES* RAND servername key) supi)) ;;store XRES* and SUPI
        (send (cat RAND (AUTN SQN RAND key) (HXRES* RAND servername key)))
        (recv (RES* RAND servername key))
        (send (cat (KSEAF RAND servername SQN key) supi))
    )
    (uniq-gen RAND)
    (non-orig SQN key)
   )
  )

;;;(defskeleton 
;;;    (vars )
;;;    (defstrandmax )
;;;)

;;;(defskeleton 
;;;    (vars )
;;;    (defstrandmax )
;;;)

;;;(defskeleton 
;;;    (vars )
;;    (defstrandmax )
;;)