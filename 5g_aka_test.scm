(herald "Pake 0"
	)

(defmacro (sKey a b na nb) 
  (hash (ltk a b) a b na nb)
  )

(defprotocol pake0 basic 
  (defrole alice
    (vars (na nb data) (a b name))
    (trace
     (send na)
     (recv nb)
     (send (hash (sKey a b na nb)))
     (recv (hash (hash (sKey a b na nb)) (sKey a b na nb)))
     )
    )

  (defrole bob
    (vars (na nb data) (a b name))
    (trace
     (recv na)
     (send nb)
     (recv (hash (sKey a b na nb)))
     (send (hash (hash (sKey a b na nb)) (sKey a b na nb)))
     )
    )
  )

(defskeleton pake0
  (vars (na data) (a b name))
  (defstrand alice 4 (na na) (a a) (b b))
  (uniq-orig na)
  (pen-non-orig (ltk a b))
  )

(defskeleton pake0
  (vars (nb data) (a b name))
  (defstrand bob 4 (nb nb) (a a) (b b))
  (uniq-orig nb)
  (uniq-orig nb)
  )
