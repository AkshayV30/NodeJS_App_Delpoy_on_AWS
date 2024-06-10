// hello world

const express =require('express');
const app = express();
const port = 3000;
// const port = process.env.PORT || 80; // using environment variable or default to 80

app.get('/',(req,res)=>{

   res.send(`
      <h1>  hello World : Pearl Thoughts v3.2 </h1>`);

});

app.listen(port , ()=>{
   console.log(`App is listning on http://localhost:${port}`)

})