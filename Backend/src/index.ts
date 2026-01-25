import app from "./app.js";
import dotenv from "dotenv";

dotenv.config();

const PORT = Number(process.env.PORT)|| 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[server]: Server is running at http://0.0.0.0:${PORT}`);
});