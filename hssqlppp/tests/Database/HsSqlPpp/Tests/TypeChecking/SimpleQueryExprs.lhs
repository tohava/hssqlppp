
> {-# LANGUAGE OverloadedStrings #-}
> module Database.HsSqlPpp.Tests.TypeChecking.SimpleQueryExprs
>     (simpleQueryExprs) where

> import Database.HsSqlPpp.Internals.TypesInternal
> import Database.HsSqlPpp.Tests.TypeChecking.Utils
> import Database.HsSqlPpp.Types
> import Database.HsSqlPpp.Catalog
> --import Database.HsSqlPpp.TypeChecker


> simpleQueryExprs :: Item
> simpleQueryExprs =
>   Group "simpleQueryExpr"
>       [QueryExpr
>         [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                             ,("b", mkCatNameExtra "text")]]
>         "select a,b from t"
>         $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                 ,("b", mkTypeExtra $ ScalarType "text")]
>
>
>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select a as c,b as d from t"
>        $ Right $ CompositeType [("c", mkTypeExtra typeInt)
>                                ,("d", mkTypeExtra $ ScalarType "text")]
>
>
>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select * from t"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                ,("b", mkTypeExtra $ ScalarType "text")]
>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select t.a,t.b from t"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                ,("b", mkTypeExtra $ ScalarType "text")]

>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select u.* from t u"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                ,("b", mkTypeExtra $ ScalarType "text")]
>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select * from t u(c,d)"
>        $ Right $ CompositeType [("c", mkTypeExtra typeInt)
>                                ,("d", mkTypeExtra $ ScalarType "text")]
>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select u.a,u.b from t u"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)
>                                ,("b", mkTypeExtra $ ScalarType "text")]

>
>
>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")
>                                      ,("b", mkCatNameExtra "text")]]
>        "select count(*) from t"
>        $ Right $ CompositeType [("count", TypeExtra typeBigInt Nothing Nothing False)]


>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")]
>                  ,CatCreateTable "u" [("a", mkCatNameExtra "int4")]]
>        "select * from t union select * from u"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)]

>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")]
>                  ,CatCreateTable "u" [("b", mkCatNameExtra "int4")]]
>        "select * from t union select * from u"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt)]

todo: implicit casts in union

simple window function type

>       ,QueryExpr [CatCreateTable "t" [("a", mkCatNameExtra "int4")]]
>        "select a,count(*) over () as r from t"
>        $ Right $ CompositeType [("a", mkTypeExtra typeInt), ("r", TypeExtra typeBigInt Nothing Nothing False)]


>   ]

