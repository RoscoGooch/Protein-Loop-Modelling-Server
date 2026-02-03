import {Link, useRouteError} from "react-router-dom";
import notFound from "../assets/notFound.svg";
import otherError from "../assets/otherError.svg";

const ErrorPage = () => {
  const error = useRouteError();
  console.log(error);
  if (error.status === 404) {
    return (
        <div className="error">
            <img src={notFound} className="error-img" alt="404" />
            <h2>Sorry, we couldn't find that page!</h2>
            <Link to="/">Back to Home</Link>
        </div>
    );
} 
  return (
    <div className="error">
        <img src={otherError} className="error-img" alt="other" />
        <h2>Sorry, something went wrong!</h2>
        <Link to="/">Back to Home</Link>
    </div>
)
};

export default ErrorPage;