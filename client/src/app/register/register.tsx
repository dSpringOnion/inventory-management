"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Header from "@/app/(components)/Header";

const Register = () => {
    const router = useRouter();
    const [formData, setFormData] = useState({
        email: "",
        password: "",
        confirmPassword: "",
    });
    const [error, setError] = useState("");

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        // Basic validation
        if (formData.password !== formData.confirmPassword) {
            setError("Passwords do not match.");
            return;
        }

        try {
            const response = await fetch("/api/auth/register", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    email: formData.email,
                    password: formData.password,
                }),
            });

            if (response.ok) {
                // Redirect to login page
                router.push("/login");
            } else {
                const data = await response.json();
                setError(data.message || "An error occurred.");
            }
        } catch (err) {
            console.error(err);
            setError("An error occurred. Please try again.");
        }
    };

    return (
        <div className="flex flex-col items-center justify-center min-h-screen">
            <Header name="Register" />
            <form onSubmit={handleSubmit} className="w-full max-w-md mt-8">
                {error && (
                    <div className="mb-4 text-red-600 text-center font-semibold">
                        {error}
                    </div>
                )}
                <div className="mb-4">
                    <label className="block mb-2 font-semibold" htmlFor="email">
                        Email
                    </label>
                    <input
                        className="w-full p-2 border rounded"
                        type="email"
                        id="email"
                        name="email"
                        placeholder="you@example.com"
                        value={formData.email}
                        onChange={handleChange}
                        required
                    />
                </div>
                <div className="mb-4">
                    <label className="block mb-2 font-semibold" htmlFor="password">
                        Password
                    </label>
                    <input
                        className="w-full p-2 border rounded"
                        type="password"
                        id="password"
                        name="password"
                        placeholder="********"
                        value={formData.password}
                        onChange={handleChange}
                        required
                    />
                </div>
                <div className="mb-6">
                    <label className="block mb-2 font-semibold" htmlFor="confirmPassword">
                        Confirm Password
                    </label>
                    <input
                        className="w-full p-2 border rounded"
                        type="password"
                        id="confirmPassword"
                        name="confirmPassword"
                        placeholder="********"
                        value={formData.confirmPassword}
                        onChange={handleChange}
                        required
                    />
                </div>
                <button
                    className="w-full px-4 py-2 font-semibold text-white bg-blue-500 rounded hover:bg-blue-700"
                    type="submit"
                >
                    Register
                </button>
            </form>
        </div>
    );
};

export default Register;