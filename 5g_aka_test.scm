(herald "5G AKA Round 1 suci "
    (comment "First attempt for modeling 5G AKA")
	)

;;macro for AUTN
(defmacro (AUTN sqn rand key)
    (cat (hash sqn (hash key rand)) (hash sqn rand key))
)

;;Protocol 5G-AKA 
(defprotocol 5G-AKA basic

  (defrole UE
    (vars (supi RAND data) (homename servername name))
    (trace
        (send (enc supi (pubk homename)))
        (recv (cat RAND (AUTN SQN RAND key)))
        

     )
    )

  (defrole ServingNetwork
    (vars (supi RAND data) (homename servername name) (SQN xRES text) (key skey))
    (trace
        (recv (enc supi (pubk homename)))
        (send (cat (enc supi (pubk homename) servername))
        (recv (cat RAND (AUTN sqn RAND key) (hash xRES RAND)))
        (send (cat RAND (AUTN SQN RAND key))) ;; ngKSI, AMF, and ABBA need to be added???
    )
    (non-orig SQN key)
   )

   (defrole HomeNetwork
    (vars (supi RAND data) (homename servername name) (SQN xRES text) (key skey))
    (trace 
        (recv (cat (enc supi (pubk homename) servername))
        (init xRES supi) ;;store XRES* and SUPI
        (send (cat RAND (AUTN SQN RAND key) (hash xRES RAND)))
        

    )
    (uniq-gen RAND)
    (non-orig SQN key)
   )
  )

(defskeleton 
    (vars )
    (defstrandmax )
)

(defskeleton 
    (vars )
    (defstrandmax )
)

(defskeleton 
    (vars )
    (defstrandmax )
)