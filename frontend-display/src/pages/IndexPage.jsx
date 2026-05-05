import UserContainer from "../components/UserContainer";
import { useAuth0 } from "@auth0/auth0-react";
import { useLocation, useNavigate } from "react-router-dom";

const IndexPage = () => {
    const navigate = useNavigate();

    const {isAuthenticated, loginWithRedirect, logout, user, isLoading} = useAuth0();
    function goToLoad() {
        navigate("/load_model");
    }

    return (
    <div>
        <h1>Welcome to the protein loop modelling server!</h1>
        <UserContainer user={user} login={loginWithRedirect} logout={logout}/>
        <button onClick={goToLoad}>Change chain and code</button>
    </div>    
    )
}

export default IndexPage;