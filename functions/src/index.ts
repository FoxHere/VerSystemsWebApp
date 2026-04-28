/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions/v2";

// import { onRequest } from "firebase-functions/https";
// import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentCreated, onDocumentUpdated, onDocumentDeleted} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {getStorage} from "firebase-admin/storage";

initializeApp();

const db = getFirestore();

type CreateAuthUserPayload = {
  email: string;
  password: string;
  displayName: string;
  customClaims?: Record<string, unknown>;
};

export const createAuthUser = onCall(async (request) => {
  const auth = request.auth;
  const {isFirstUser} = request.data as { isFirstUser: boolean };
  if (!isFirstUser) {
    if (!auth || auth.token?.admin !== true) {
      throw new HttpsError(
        "permission-denied",
        "You must be an admin to perform this action."
      );
    }
  }
  try {
    const {email, password, displayName, customClaims} =
      (request.data.userModel as CreateAuthUserPayload) ?? {};

    if (!email) throw new HttpsError("invalid-argument", "Email is required.");

    const user = await getAuth().createUser({
      email,
      password,
      displayName,
      disabled: false,
    });

    if (customClaims && Object.keys(customClaims).length) {
      await getAuth().setCustomUserClaims(user.uid, customClaims);
    }
    await changeUserDisabled(user.uid, false);
    return {uid: user.uid};
  } catch (e: any) {
    throw new HttpsError("internal", e?.message || "Error creating user.");
  }
});

export const deleteAuthUser = onCall(async (request) => {
  const auth = request.auth;
  if (!auth || auth.token?.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "You must be an admin to perform this action"
    );
  }

  try {
    const {uid} = request.data as { uid: string };

    if (!uid) throw new HttpsError("invalid-argument", "User ID is required");
    await getAuth().deleteUser(uid);
    return {success: true};
  } catch (e: any) {
    throw new HttpsError("internal", e?.message || "Error deleting user");
  }
});

async function changeUserDisabled(uid: string, disabled: boolean) {
  await getAuth().updateUser(uid, {disabled});
}

export const changeAuthUser = onCall(async (request) => {
  const auth = request.auth;
  if (!auth || auth.token?.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "You must be an admin to perform this action"
    );
  }
  try {
    const {uid, disabled} = request.data as { uid: string, disabled: boolean };
    if (!uid) throw new HttpsError("invalid-argument", "User ID is required");
    await changeUserDisabled(uid, disabled);

    return {success: true};
  } catch (e: any) {
    throw new HttpsError("internal", e?.message || "Error changing user");
  }
});

// ==================== DASHBOARD UPDATE FUNCTIONS ====================

/**
 * Atualiza o dashboard quando uma activity é criada, atualizada ou deletada
 */
export const updateDashboardOnActivityChange = onDocumentCreated(
  "branches/{companyId}/activities/{activityId}",
  async (event) => {
    const companyId = event.params.companyId;
    logger.info("Activity created, updating dashboard", {activityId: event.params.activityId});
    await updateDashboardActivities(companyId);
    await updateDashboardPendentTasks(companyId);
  }
);

export const updateDashboardOnActivityUpdate = onDocumentUpdated(
  "branches/{companyId}/activities/{activityId}",
  async (event) => {
    logger.info("Activity updated, updating dashboard", {activityId: event.params.activityId});
    const companyId = event.params.companyId;
    await updateDashboardActivities(companyId);
    await updateDashboardPendentTasks(companyId);
  }
);

export const updateDashboardOnActivityDelete = onDocumentDeleted(
  "branches/{companyId}/activities/{activityId}",
  async (event) => {
    logger.info("Activity deleted, updating dashboard", {activityId: event.params.activityId});
    const companyId = event.params.companyId;
    const taskId = event.params.activityId;

    await deleteTaskImages(taskId);
    await updateDashboardActivities(companyId);
    await updateDashboardPendentTasks(companyId);
  }
);

/**
 * Atualiza o dashboard quando um formulário é criado, atualizado ou deletado
 */
export const updateDashboardOnFormularyChange = onDocumentCreated(
  "branches/{companyId}/formularies/{formularyId}",
  async (event) => {
    logger.info("Formulary created, updating dashboard", {formularyId: event.params.formularyId});
    const companyId = event.params.companyId;
    await updateDashboardFormularies(companyId);
  }
);

export const updateDashboardOnFormularyUpdate = onDocumentUpdated(
  "branches/{companyId}/formularies/{formularyId}",
  async (event) => {
    logger.info("Formulary updated, updating dashboard", {formularyId: event.params.formularyId});
    const companyId = event.params.companyId;
    await updateDashboardFormularies(companyId);
  }
);

export const updateDashboardOnFormularyDelete = onDocumentDeleted(
  "branches/{companyId}/formularies/{formularyId}",
  async (event) => {
    logger.info("Formulary deleted, updating dashboard", {formularyId: event.params.formularyId});
    const companyId = event.params.companyId;
    await updateDashboardFormularies(companyId);
  }
);

/**
 * Atualiza o dashboard quando um usuário é criado, atualizado ou deletado
 */
export const updateDashboardOnUserChange = onDocumentCreated(
  "branches/{companyId}/users/{userId}",
  async (event) => {
    const companyId = event.params.companyId;
    logger.info("User created, updating dashboard", {userId: event.params.userId});
    await updateDashboardMembers(companyId);
    await updateDashboardPendentTasks(companyId);
  }
);

export const updateDashboardOnUserUpdate = onDocumentUpdated(
  "branches/{companyId}/users/{userId}",
  async (event) => {
    const companyId = event.params.companyId;
    logger.info("User updated, updating dashboard", {userId: event.params.userId});
    await updateDashboardMembers(companyId);
    await updateDashboardPendentTasks(companyId);
  }
);

export const updateDashboardOnUserDelete = onDocumentDeleted(
  "branches/{companyId}/users/{userId}",
  async (event) => {
    const companyId = event.params.companyId;
    logger.info("User deleted, updating dashboard", {userId: event.params.userId});
    await updateDashboardMembers(companyId);
    await updateDashboardPendentTasks(companyId);
  }
);

// ==================== HELPER FUNCTIONS ====================

/**
 * Função para inicializar o dashboard com dados existentes
 * Pode ser chamada manualmente se necessário
 */
export const initializeDashboard = onCall(async (request) => {
  const auth = request.auth;

  if (!auth || auth.token?.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "You must be an admin to perform this action."
    );
  }

  const {companyId} = request.data;
  if (!companyId) {
    throw new HttpsError("invalid-argument", "Company ID is required");
  }

  try {
    logger.info("Initializing dashboard with existing data");

    await updateDashboardActivities(companyId);
    await updateDashboardFormularies(companyId);
    await updateDashboardMembers(companyId);
    await updateDashboardPendentTasks(companyId);

    logger.info("Dashboard initialized successfully");
    return {success: true, message: "Dashboard initialized successfully"};
  } catch (error) {
    logger.error("Error initializing dashboard", error);
    throw new HttpsError("internal", "Error initializing dashboard");
  }
});

async function deleteTaskImages(companyId: string) {
  try {
    const bucket = getStorage().bucket();
    const folder = `tasks/${companyId}`;

    // Deleta todas as imagens da pasta
    await bucket.deleteFiles({prefix: folder});
    logger.info("Task images deleted successfully", {folder});
  } catch (error) {
    logger.error("Error deleting task images", error);
    throw error;
  }
}

/**
 * Atualiza as estatísticas de activities no dashboard
 */
async function updateDashboardActivities(companyId: string) {
  try {
    const activitiesSnapshot = await db.collection(`branches/${companyId}/activities`).get();
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    let total = 0;
    let totalThisMonth = 0;
    const profile = 0;

    activitiesSnapshot.forEach((doc) => {
      const data = doc.data();
      total++;

      // Verifica se a activity foi criada este mês
      if (data.createdAt && data.createdAt.toDate() >= startOfMonth) {
        totalThisMonth++;
      }

      // Conta activities com perfil específico (ajuste conforme sua lógica)
      // if (data.profile) {
      //   profile++;
      // }
    });

    await updateDashboardField(companyId, "activities", {
      profile,
      total,
      total_this_month: totalThisMonth,
    });

    logger.info("Dashboard activities updated", {total, totalThisMonth, profile});
  } catch (error) {
    logger.error("Error updating dashboard activities", error);
    throw error;
  }
}

/**
 * Atualiza as estatísticas de formularies no dashboard
 */
async function updateDashboardFormularies(companyId: string) {
  try {
    const formulariesSnapshot = await db.collection(`branches/${companyId}/formularies`).get();
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    let total = 0;
    let totalThisMonth = 0;
    const profile = 0;

    formulariesSnapshot.forEach((doc) => {
      const data = doc.data();
      total++;

      // Verifica se o formulário foi criado este mês
      if (data.createdAt && data.createdAt.toDate() >= startOfMonth) {
        totalThisMonth++;
      }

      // Conta formulários com perfil específico (ajuste conforme sua lógica)
      // if (data.profile) {
      //   profile++;
      // }
    });

    await updateDashboardField(companyId, "formularies", {
      profile,
      total,
      total_this_month: totalThisMonth,
    });

    logger.info("Dashboard formularies updated", {total, totalThisMonth, profile});
  } catch (error) {
    logger.error("Error updating dashboard formularies", error);
    throw error;
  }
}

/**
 * Atualiza as estatísticas de members no dashboard
 */
async function updateDashboardMembers(companyId: string) {
  try {
    const usersSnapshot = await db.collection("users").get();
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    let total = 0;
    let totalThisMonth = 0;
    const profile = 0;

    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      total++;

      // Verifica se o usuário foi criado este mês
      if (data.createdAt && data.createdAt.toDate() >= startOfMonth) {
        totalThisMonth++;
      }

      // Conta usuários com perfil específico (ajuste conforme sua lógica)
      // if (data.profile) {
      //   profile++;
      // }
    });

    await updateDashboardField(companyId, "members", {
      profile,
      total,
      total_this_month: totalThisMonth,
    });

    logger.info("Dashboard members updated", {total, totalThisMonth, profile});
  } catch (error) {
    logger.error("Error updating dashboard members", error);
    throw error;
  }
}

/**
 * Atualiza as estatísticas de pendentTasks no dashboard
 */
async function updateDashboardPendentTasks(companyId: string) {
  try {
    const activitiesSnapshot = await db.collection(`branches/${companyId}/activities`).get();
    const usersMap = new Map<string, { total: number; totalThisMonth: number; profile: number }>();
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // let totalProfile = 0;

    activitiesSnapshot.forEach((doc) => {
      const data = doc.data();

      // Verifica se a atividade tem um responsável e está ativa
      if (data.responsible && data.responsible.id && data.status === "active") {
        const userId = data.responsible.id;

        // Inicializa o usuário no mapa se não existir
        if (!usersMap.has(userId)) {
          usersMap.set(userId, {total: 0, totalThisMonth: 0, profile: 0});
        }

        const userStats = usersMap.get(userId)!;
        userStats.total++;

        // Verifica se a atividade foi criada este mês
        if (data.createdAt && data.createdAt.toDate() >= startOfMonth) {
          userStats.totalThisMonth++;
        }

        // Conta atividades com perfil específico (ajuste conforme sua lógica)
        // if (data.responsible.profile) {
        //   userStats.profile++;
        //   totalProfile++;
        // }
      }
    });

    // Converte o mapa para o formato esperado pelo dashboard
    const usersObject: { [key: string]: any } = {};
    usersMap.forEach((stats, userId) => {
      usersObject[userId] = {
        profile: 0,
        total: stats.total,
        total_this_month: stats.totalThisMonth,
      };
    });

    await updateDashboardField(companyId, "pendentTasks", {
      profile: 0,
      users: usersObject,
    });

    logger.info("Dashboard pendentTasks updated", {
      totalUsers: usersMap.size,
      totalProfile: 0,
      users: Object.keys(usersObject),
    });
  } catch (error) {
    logger.error("Error updating dashboard pendentTasks", error);
    throw error;
  }
}

/**
 * Atualiza um campo específico do documento dashboard
 */
async function updateDashboardField(companyId: string, fieldName: string, data: any) {
  try {
    const dashboardRef = db.collection(`branches/${companyId}/dashboard`).doc("main");
    const dashboardDoc = await dashboardRef.get();

    if (!dashboardDoc.exists) {
      // Se o documento não existe, cria com estrutura vazia
      await dashboardRef.set({
        formularies: {profile: 1000, total: 0, total_this_month: 0},
        activities: {profile: 1000, total: 0, total_this_month: 0},
        pendentTasks: {profile: 0, users: {}},
        members: {profile: 1000, total: 0, total_this_month: 0},
      });
    }

    // Atualiza o campo específico
    await dashboardRef.update({
      [fieldName]: data,
    });

    logger.info(`Dashboard field ${fieldName} updated successfully`);
  } catch (error) {
    logger.error(`Error updating dashboard field ${fieldName}`, error);
    throw error;
  }
}
