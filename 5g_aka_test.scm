(herald "5G AKA Round 1 suci "
    (comment "First attempt for modeling 5G AKA")
	)

(defmacro (AUTN sqn rand key)
    (cat (hash sqn (hash key rand)) (hash sqn rand key))
)

(defprotocol 5G-AKA basic

  (defrole UE
    (vars (supi RAND data) (homename servername name))
    (trace
        (send (enc supi (pubk homename)))

     )
    )

  (defrole ServingNetwork
    (vars (supi RAND data) (homename servername name))
    (trace
        (recv (enc supi (pubk homename)))
        (send (cat (enc supi (pubk homename) servername))
        (recv (cat RAND ))
    )
    (non-orig seqno)
   )

   (defrole HomeNetwork
    (vars (supi RAND data) (homename servername name) (seqno text))
    (trace 
        (recv (cat (enc supi (pubk homename) servername))
        (send (cat RAND AUTN ))
    )
    (uniq-gen RAND)
    (non-orig seqno)
    
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
)()