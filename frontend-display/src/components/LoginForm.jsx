const LoginForm = () => {
    return <>
        <form>
            <label className="form-label">
                Username
                <input id="username"></input>
            </label>
            <label className="form-label">
                Password
                <input id="password"></input>
            </label>
        </form>
    </>
}

export default LoginForm;