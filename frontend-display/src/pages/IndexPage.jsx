import UserContainer from "../components/UserContainer";
import SampleModelContainer from "../components/SampleModelContainer";
import { useAuth0 } from "@auth0/auth0-react";
import { useLocation, useNavigate } from "react-router-dom";

const IndexPage = () => {
    const navigate = useNavigate();

    const {isAuthenticated, loginWithRedirect, logout, user, isLoading} = useAuth0();
    function goToLoad() {
        navigate("/load_model");
    }

    return (
    <div id="openingPage">
        <h1>Welcome to the protein loop modelling server!</h1>
        <UserContainer user={user} login={loginWithRedirect} logout={logout}/>
        <h2>This server shows how to measure the effect of end constraints on protein loop kinematics</h2>
        <SampleModelContainer/>
        <button onClick={goToLoad} id='startButton'>Get started</button>
        <p>For more information see</p><a href="https://www.sciencedirect.com/science/article/pii/S0006349510001475" target="_blank">The Effect of End Constraints on Protein Loop Kinematics</a>
    </div>    
    )
}

export default IndexPage;