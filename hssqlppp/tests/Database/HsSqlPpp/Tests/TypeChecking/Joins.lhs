
> {-# LANGUAGE OverloadedStrings #-}
> module Database.HsSqlPpp.Tests.TypeChecking.Joins
>     (joins) where

> import Database.HsSqlPpp.Internals.TypesInternal
> import Database.HsSqlPpp.Tests.TypeChecking.Utils
> import Database.HsSqlPpp.Types
> import Database.HsSqlPpp.Catalog


> joins :: Item
> joins =
>   Group "joins"
>   [qe "select * from t0 cross join t1"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                               ,("b", mkTypeExtra $ ScalarType "text")
>                               ,("c", mkTypeExtra typeInt)
>                               ,("d", mkTypeExtra $ ScalarType "text")]
>   ,qe "select a from t0 cross join t1"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)]
>   ,qe "select b from t0 cross join t1"
>       $ Right $ CompositeType [("b", mkTypeExtra $ ScalarType "text")]
>   ,qe "select c from t0 cross join t1"
>       $ Right $ CompositeType [("c", mkTypeExtra typeInt)]
>   ,qe "select d from t0 cross join t1"
>       $ Right $ CompositeType [("d", mkTypeExtra $ ScalarType "text")]
>   ,qe "select a,b,c,d from t0 cross join t1"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                               ,("b", mkTypeExtra $ ScalarType "text")
>                               ,("c", mkTypeExtra typeInt)
>                               ,("d", mkTypeExtra $ ScalarType "text")]
>
>   ,qe "select * from (select 1 as a, 2 as b) a\n\
>       \  cross join (select true as c, 4.5 as d) b;"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                               ,("b", mkTypeExtra typeInt)
>                               ,("c", mkTypeExtra typeBool)
>                               ,("d", mkTypeExtra typeNumeric)]
>   ,qe "select * from (select 1 as a, 2 as b) a\n\
>       \  inner join (select true as c, 4.5 as d) b on true;"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                               ,("b", mkTypeExtra typeInt)
>                               ,("c", mkTypeExtra typeBool)
>                               ,("d", mkTypeExtra typeNumeric)]
>   ,qe "select * from (select 1 as a, 2 as b) a\n\
>       \  inner join (select 1 as a, 4.5 as d) b using(a);"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                               ,("b", mkTypeExtra typeInt)
>                               ,("d", mkTypeExtra typeNumeric)]
>   ,qe "select * from (select 1 as a, 2 as b) a\n\
>         \  natural inner join (select 1 as a, 4.5 as d) b;"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                ,("b", mkTypeExtra typeInt)
>                                ,("d", mkTypeExtra typeNumeric)]
>         --check the attribute order
>   ,qe "select * from (select 2 as b, 1 as a) a\n\
>       \ natural inner join (select 4.5 as d, 1 as a) b;"
>         $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                 ,("b", mkTypeExtra typeInt)
>                                 ,("d", mkTypeExtra typeNumeric)]
>         -- todo: need to fix this so that the star
>         -- expand error doesn't appear: better error
>         -- handling in the environment
>   ,qe "select * from (select 1 as a1, 2 as b) a\n\
>         \ natural inner join (select true as a1, 4.5 as d) b;"
>         $ Left [IncompatibleTypeSet [ScalarType "int4"
>                                     ,ScalarType "bool"]]
>   ,qe "select * from (select 1 as a1, 2 as b) a\n\
>         \ natural inner join (select true as a1, 4.5 as d) b;"
>         $ Left [IncompatibleTypeSet [ScalarType "int4"
>                                     ,ScalarType "bool"]]
>   ,qe "select * from (select 1 as a1) a, (select 2 as a2) b;"
>         $ Right $ CompositeType [("a1", mkTypeExtra typeInt)
>                                 ,("a2", mkTypeExtra typeInt)]
>   -- needs tref aliases in env
>   ,qe "select * from (select 1 as a1) a, (select 2 as a1) b;"
>         $ Right $ CompositeType [("a1", mkTypeExtra typeInt)
>                                 ,("a1", mkTypeExtra typeInt)]
>   ,qe "select a1 from (select 1 as a1) a,  (select 2 as a1) b;"
>         $ Left [AmbiguousIdentifier "a1"]

>   ,qe "select a from t0 inner join t1 on t0.a = t1.c;"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)]
>   ,qe "select x.a from (select * from t0) x \n\
>       \ inner join t1 Y on X.a = Y.C"
>       $ Right $ CompositeType [("a", mkTypeExtra typeInt)]

>   ]
>   where
>     qe = QueryExpr [CatCreateTable "t0" [("a", mkCatNameExtra "int4")
>                                         ,("b", mkCatNameExtra "text")]
>                    ,CatCreateTable "t1" [("c", mkCatNameExtra "int4")
>                                         ,("d", mkCatNameExtra "text")]]
