// hello world

const express =require('express');
const app =express();
// const PORT =3000;
const port = process.env.PORT || 80; // using environment variable or default to 80

app.get('/',(req,res)=>{

   res.send("hello PearlThoughts v3.1");

});

app.listen(PORT ,()=>{
   console.log(`App is listning on http://localhost:${PORT}`)

})