// Test file to verify Claude Code Review is working
// This file contains various patterns that should trigger different review feedback

const API_KEY = "sk-test-12345"; // Intentional: hardcoded credential for testing

function calculateSum(a, b) {
    // Missing input validation
    return a + b;
}

// Missing error handling
async function fetchData(url) {
    const response = await fetch(url);
    const data = await response.json();
    return data;
}

// Performance issue: inefficient loop
function findItem(items, target) {
    for (let i = 0; i < items.length; i++) {
        for (let j = 0; j < items.length; j++) {
            if (items[i] === target) {
                return i;
            }
        }
    }
    return -1;
}

// Missing JSDoc comments
function processUserData(user) {
    if (!user.email) {
        throw new Error("Email required");
    }
    
    return {
        id: user.id,
        name: user.name,
        email: user.email.toLowerCase()
    };
}

module.exports = {
    calculateSum,
    fetchData,
    findItem,
    processUserData
};