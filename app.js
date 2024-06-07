// hello world

const express =require('express');
const app =express();
const PORT =3000;

app.get('/',(req,res)=>{

   res.send("hello PearlThoughts v2");

});

app.listen(PORT ,()=>{
   console.log(`App is listning on http://localhost:${PORT}`)

})