import { useAuth0 } from "@auth0/auth0-react";

const ForceLogin = () => {
    const {loginWithRedirect} = useAuth0();
    return(
    <>
    <div className="forceLogin">
      <h1>Sign in to use this feature</h1>
      <button onClick={loginWithRedirect}>Login</button>
    </div>
    </>
    )
}

export default ForceLogin;