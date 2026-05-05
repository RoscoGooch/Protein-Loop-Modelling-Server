import {useNavigate, useLocation} from "react-router-dom";

const UserContainer = ({user, logout, login}) => {
    const navigate = useNavigate();
    const location = useLocation();
    let path = true;
    if (location.pathname === "/login") {
        path = false;
    }
    if (!path) {
        return (
        <div className ="user-container">
            <div className="user-container-link"></div>
        </div>
        )
    } else {    
    return (
        <div className="user-container">
            <div className="user-container-link">
                {path && !user ? (
                    <>
                    {" "}
                    <button onClick={login}>
                        Login
                    </button>
                    </>
                ) : (
                    <>
                        <span>{"Welcome! "}</span>
                        <span>
                            {user?.username?.toUpperCase()} {user?.name?.toUpperCase()}
                        </span>
                        <span>
                            {user?.picture && <img className="user-img" src={user.picture} alt={user.name} />}
                        </span>
                        <button
                         onClick={() => {
                         console.log("logout");
                         logout({ returnTo: window.location.origin });
                         }}
                        >
                            logout
                        </button>   
                    </>
                )}
            </div>
        </div>
    )
    }
}

export default UserContainer;